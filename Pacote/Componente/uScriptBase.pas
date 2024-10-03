unit uScriptBase;

interface

uses
  System.Classes, Data.Win.ADODB, System.SysUtils;

type
  TScriptBase = class(TPersistent)
  protected
    procedure CriarCampo(const prTabela, prCampo, prTipo, prDescricao: string);
    procedure CriarTabela(const prTabela, prDescricao, prDescricaoGerenciamento: string);
    procedure CriarForeignKey(const prTabela, prTabelaReferencia, prCampo: string);

    procedure InserirRegistro(const prTabela, prCampo, prValor: string);

    function ExisteTabela(const prTabela: string): Boolean;
    function ExisteForeignKey(const prTabela, prTabelaReferencia, prCampo: string): Boolean;
  public
    procedure Execute(); virtual; abstract;
  end;

implementation

uses
  uMyQuery,
  uSistema;

{ TScriptBase }

procedure TScriptBase.CriarCampo(const prTabela, prCampo, prTipo, prDescricao: string);
var
  vObjectID: string;
  vHandleTabela: Integer;

  vQuery: TMyQuery;
  vCommand: TADOCommand;
begin
  vQuery := TMyQuery.Create(nil);
  vCommand := TADOCommand.Create(nil);
  try
    vQuery.SQL.Text := ' SELECT A.HANDLE ' +
                       '   FROM MD_CAMPO A ' +
                       '  INNER JOIN MD_TABELA B ON B.HANDLE = A.TABELA ' +
                       '  WHERE A.NOME = :CAMPO ' +
                       '    AND B.NOME = :TABELA ';
    vQuery.Parameters.ParamByName('CAMPO').Value := prCampo;
    vQuery.Parameters.ParamByName('TABELA').Value := prTabela;
    vQuery.Active := True;

    if vQuery.Eof then
    begin
      vCommand.Connection := Sistema.GetConexao;

      vQuery.SQL.Text := ' SELECT A.OBJECT_ID ' +
                         '   FROM SYS.TABLES A ' +
                         '  WHERE A.NAME = :TABELA ';
      vQuery.Parameters.ParamByName('TABELA').Value := prTabela;
      vQuery.Active := True;

      if not vQuery.Eof then
      begin
        vObjectID := vQuery.FieldByName('OBJECT_ID').AsString;

        vQuery.SQL.Text := ' SELECT A.HANDLE ' +
                           '   FROM MD_TABELA A ' +
                           '  WHERE A.NOME = :TABELA ';
        vQuery.Parameters.ParamByName('TABELA').Value := prTabela;
        vQuery.Active := True;

        vHandleTabela := vQuery.FieldByName('HANDLE').AsInteger;

        if vHandleTabela <> 0 then
        begin
          vQuery.SQL.Text := ' SELECT COLUMN_ID ' +
                             '   FROM SYS.COLUMNS ' +
                             '  WHERE NAME = :COLUNA ' +
                             '    AND OBJECT_ID = ' + vObjectID;
          vQuery.Parameters.ParamByName('COLUNA').Value := prCampo;
          vQuery.Active := True;

          if vQuery.Eof then
          begin
            vCommand.CommandText := ' ALTER TABLE ' + prTabela +
                                    ' ADD ' + prCampo + ' ' + prTipo;
            vCommand.Execute();
          end;

          //-- CRIA MD_CAMPO
          vQuery.SQL.Text := ' SELECT MAX(HANDLE) HANDLE FROM MD_CAMPO ';
          vQuery.Active := True;

          vCommand.CommandText := ' INSERT MD_CAMPO ( HANDLE, TABELA, NOME, DESCRICAO ) ' +
                                  ' VALUES ( :HANDLE, :TABELA, :NOME, :DESCRICAO ) ';
          vCommand.Parameters.ParamByName('HANDLE').Value := vQuery.FieldByName('HANDLE').AsInteger + 1;
          vCommand.Parameters.ParamByName('NOME').Value := prCampo;
          vCommand.Parameters.ParamByName('TABELA').Value := vHandleTabela;
          vCommand.Parameters.ParamByName('DESCRICAO').Value := prDescricao;
          vCommand.Execute();
        end;
      end;
    end;
  finally
    vQuery.Free;
    vCommand.Free;
  end;
end;

procedure TScriptBase.CriarForeignKey(const prTabela, prTabelaReferencia, prCampo: string);
var
  vCommand: TADOCommand;
begin
  vCommand := TADOCommand.Create(nil);
  try
    if not ExisteForeignKey(prTabela, prTabelaReferencia, prCampo) then
    begin
      vCommand.Connection := Sistema.GetConexao;
      vCommand.CommandText :=
        ' ALTER TABLE ' + prTabela +
        ' ADD CONSTRAINT FK_' + prCampo + '_' + prTabelaReferencia +
        ' FOREIGN KEY (' + prCampo + ') REFERENCES ' + prTabelaReferencia + ' (HANDLE)';
      vCommand.Execute();
    end;
  finally
    vCommand.Free;
  end;
end;

procedure TScriptBase.CriarTabela(const prTabela, prDescricao, prDescricaoGerenciamento: string);
var
  vQuery: TMyQuery;
  vCommand: TADOCommand;
begin
  vQuery := TMyQuery.Create(nil);
  vCommand := TADOCommand.Create(nil);
  try
    vCommand.Connection := Sistema.GetConexao;

    if not ExisteTabela(prTabela) then
    begin;
      //-- CRIA TABELA
      vCommand.CommandText := ' CREATE TABLE ' + prTabela + ' ( HANDLE INTEGER NOT NULL )';
      vCommand.Execute;

      //-- CRIA PRIMARY KEY
      vCommand.CommandText := ' ALTER TABLE ' + prTabela +
                              ' ADD CONSTRAINT PK_' + prTabela + ' PRIMARY KEY (HANDLE) ';
      vCommand.Execute();
    end;

    vQuery.SQL.Text := ' SELECT HANDLE FROM MD_TABELA WHERE NOME = :NOME';
    vQuery.Parameters.ParamByName('NOME').Value := prTabela;
    vQuery.Active := True;

    if vQuery.Eof then
    begin
      //-- CRIA MD_TABELA
      vQuery.SQL.Text := ' SELECT MAX(HANDLE) HANDLE FROM MD_TABELA ';
      vQuery.Active := True;

      vCommand.CommandText := ' INSERT MD_TABELA ( HANDLE, NOME, DESCRICAO, DESCRICAOGERENCIAMENTO ) ' +
                              ' VALUES ( :HANDLE, :TABELA, :DESCRICAO, :DESCRICAOGERENCIAMENTO ) ';
      vCommand.Parameters.ParamByName('HANDLE').Value := vQuery.FieldByName('HANDLE').AsInteger + 1;
      vCommand.Parameters.ParamByName('TABELA').Value := prTabela;
      vCommand.Parameters.ParamByName('DESCRICAO').Value := prDescricao;
      vCommand.Parameters.ParamByName('DESCRICAOGERENCIAMENTO').Value := prDescricaoGerenciamento;
      vCommand.Execute;

      CriarCampo(prTabela, 'HANDLE', 'INTEGER NOT NULL', 'Código');
      CriarCampo(prTabela, 'STATUS', 'INTEGER', 'Status');
      CriarForeignKey(prTabela, 'MD_STATUS', 'STATUS');
    end;
  finally
    vQuery.Free;
    vCommand.Free();
  end;
end;

function TScriptBase.ExisteForeignKey(const prTabela, prTabelaReferencia, prCampo: string): Boolean;
var
  vQuery: TMyQuery;
begin
  vQuery := TMyQuery.Create(nil);
  try
    vQuery.SQL.Text := ' SELECT OBJECT_ID ' +
                       '   FROM SYS.FOREIGN_KEYS ' +
                       '  WHERE NAME = :NOMEPK ';
    vQuery.Parameters.ParamByName('NOMEPK').Value := 'FK_' + prCampo + '_' + prTabelaReferencia;
    vQuery.Active := True;

    Result := not vQuery.Eof;
  finally
    vQuery.Free;
  end;
end;

function TScriptBase.ExisteTabela(const prTabela: string): Boolean;
var
  vQuery: TMyQuery;
begin
  vQuery := TMyQuery.Create(nil);
  try
    vQuery.SQL.Text := ' SELECT OBJECT_ID ' +
                       '   FROM SYS.TABLES ' +
                       '  WHERE NAME = :TABELA ';
    vQuery.Parameters.ParamByName('TABELA').Value := prTabela;
    vQuery.Active := True;

    Result := not vQuery.Eof;
  finally
    vQuery.Free;
  end;
end;

procedure TScriptBase.InserirRegistro(const prTabela, prCampo, prValor: string);
var
  vQuery: TMyQuery;
  vNewHandle: string;
  vCommand: TADOCommand;
begin
  vQuery := TMyQuery.Create(nil);
  vCommand := TADOCommand.Create(nil);
  try
    vQuery.SQL.Text := ' SELECT HANDLE ' +
                       '   FROM ' + prTabela +
                       '  WHERE ' + prCampo + ' = :VALOR ';
    vQuery.Parameters.ParamByName('VALOR').Value := prValor;
    vQuery.Active := True;

    if vQuery.Eof then
    begin
      vQuery.SQL.Text := ' SELECT MAX(HANDLE) HANDLE FROM ' + prTabela;
      vQuery.Active := True;

      vNewHandle := IntToStr(vQuery.FieldByName('HANDLE').AsInteger + 1);

      vCommand.Connection := Sistema.GetConexao;
      vCommand.CommandText :=
        ' INSERT ' + prTabela + ' (HANDLE, ' + prCampo + ') ' +
        ' VALUES ( ' + vNewHandle + ', :VALOR ) ';
      vCommand.Parameters.ParamByName('VALOR').Value := prValor;
      vCommand.Execute();
    end;
  finally
    vQuery.Free;
    vCommand.Free();
  end;
end;

initialization
  RegisterClass(TScriptBase);

end.
