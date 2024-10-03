unit uScript;

interface

uses
  System.Classes, System.SysUtils, Data.DB, Data.Win.ADODB,
  //
  uScriptBase, uMyQuery, uSistema;

type
  TMDScript = class(TScriptBase)
  private
    //-- CONTEUDO
    procedure ExecuteMD_STATUS();
//    procedure ExecuteMD_TIPOCAMPO();

    procedure ExecuteMD_TABELA();
    procedure ExecuteMD_CAMPO();
    procedure ExecuteMD_TELAGERENCIAMENTO();
    procedure ExecuteMD_TELAGERENCIAMENTOCAMPO();

    //-- TABELA CONTEUDO
    //
  public
    procedure Execute(); override;
  end;

implementation

{ TMDScript }

procedure TMDScript.Execute;
begin
  //-- TABELA CONTEUDO
  ExecuteMD_STATUS();
  //ExecuteMD_TIPOCAMPO();

  ExecuteMD_TABELA();
  ExecuteMD_CAMPO();
  ExecuteMD_TELAGERENCIAMENTO();
  ExecuteMD_TELAGERENCIAMENTOCAMPO();
end;

procedure TMDScript.ExecuteMD_TABELA;
var
  vQuery: TMyQuery;
  vCommand: TADOCommand;
begin
  vQuery := TMyQuery.Create(nil);
  vCommand := TADOCommand.Create(nil);
  try
    vQuery.SQL.Text := ' SELECT A.OBJECT_ID ' +
                       '   FROM SYS.TABLES A ' +
                       '  WHERE A.NAME = :TABELA ';
    vQuery.Parameters.ParamByName('TABELA').Value := 'MD_TABELA';
    vQuery.Active := True;

    if vQuery.Eof then
    begin
      vCommand.Connection := Sistema.GetConexao;

      vCommand.CommandText :=
        ' CREATE TABLE MD_TABELA ( ' +
        '   HANDLE INTEGER NOT NULL, ' +
        '   NOME VARCHAR(40), ' +
        '   DESCRICAO VARCHAR(100), ' +
        '   DESCRICAOGERENCIAMENTO VARCHAR(100) ' +
        ' ) ';
      vCommand.Execute();

      //-- CRIA PRIMARY KEY
      vCommand.CommandText := ' ALTER TABLE MD_TABELA ' +
                              ' ADD CONSTRAINT PK_MD_TABELA PRIMARY KEY (HANDLE) ';
      vCommand.Execute();
    end;
  finally
    vCommand.Free;
  end;
end;

procedure TMDScript.ExecuteMD_TELAGERENCIAMENTO;
const
  vTabela: string = 'MD_TELAGERENCIAMENTO';
begin
  CriarTabela(vTabela, 'Tela de gerenciamento', 'Tela de gerenciamento');

  CriarCampo(vTabela, 'NOME', 'VARCHAR(50)', 'Nome');
  CriarCampo(vTabela, 'TITULO', 'VARCHAR(50)', 'Título');
  CriarCampo(vTabela, 'TABELA', 'INTEGER', 'Tabela');

  CriarForeignKey(vTabela, 'MD_TABELA', 'TABELA');
end;

procedure TMDScript.ExecuteMD_TELAGERENCIAMENTOCAMPO;
const
  vTabela: string = 'MD_TELAGERENCIAMENTOCAMPO';
begin
  CriarTabela(vTabela, 'Campo da tela de gerenciamento', 'Campo da tela de gerenciamento');

  CriarCampo(vTabela, 'INDICECOLUNA', 'INTEGER', 'Indice');
  CriarCampo(vTabela, 'NOME', 'VARCHAR(50)', 'Nome');
  CriarCampo(vTabela, 'DESCRICAO', 'VARCHAR(50)', 'Descrição');
  CriarCampo(vTabela, 'TELAGERENCIAMENTO', 'INTEGER', 'Tela de gerenciamento');
  CriarCampo(vTabela, 'LARGURA', 'INTEGER', 'Largura');
  //CriarCampo(vTabela, 'TIPOCAMPO', 'INTEGER', 'Tipo de campo');

  CriarForeignKey(vTabela, 'MD_TELAGERENCIAMENTO', 'TELAGERENCIAMENTO');
  //CriarForeignKey(vTabela, 'MD_TIPOCAMPO', 'TIPOCAMPO');
end;

{procedure TMDScript.ExecuteMD_TIPOCAMPO;
const
  vTabela: string = 'MD_TIPOCAMPO';
begin
  CriarTabela(vTabela, 'Tipo de campo', 'Tipo de campo');

  CriarCampo(vTabela, 'NOME', 'VARCHAR(50)', 'Tipo de campo');

  InserirRegistro(vTabela, 'NOME', 'STRING');
  InserirRegistro(vTabela, 'NOME', 'INTEGER');
  InserirRegistro(vTabela, 'NOME', 'DATE');
  InserirRegistro(vTabela, 'NOME', 'DATETIME');
  InserirRegistro(vTabela, 'NOME', 'NUMERIC');
end;}

procedure TMDScript.ExecuteMD_CAMPO;
var
  vQuery: TMyQuery;
  vCommand: TADOCommand;
begin
  vQuery := TMyQuery.Create(nil);
  vCommand := TADOCommand.Create(nil);
  try
    vQuery.SQL.Text := ' SELECT A.OBJECT_ID ' +
                       '   FROM SYS.TABLES A ' +
                       '  WHERE A.NAME = :TABELA ';
    vQuery.Parameters.ParamByName('TABELA').Value := 'MD_CAMPO';
    vQuery.Active := True;

    if vQuery.Eof then
    begin
      vCommand.Connection := Sistema.GetConexao;

      vCommand.CommandText :=
        ' CREATE TABLE MD_CAMPO ( ' +
        '   HANDLE INTEGER NOT NULL, ' +
        '   NOME VARCHAR(40), ' +
        '   DESCRICAO VARCHAR(100), ' +
        '   TABELA INTEGER NOT NULL, ' +
        '   OBSERVACAO VARCHAR(200) ' +
        ' ) ';
      vCommand.Execute();

      //-- CRIA PRIMARY KEY
      vCommand.CommandText := ' ALTER TABLE MD_CAMPO ' +
                              ' ADD CONSTRAINT PK_MD_CAMPO PRIMARY KEY (HANDLE) ';
      vCommand.Execute();

      //-- CRIA FOREIGN KEY
      vCommand.CommandText := ' ALTER TABLE MD_CAMPO ' +
                              ' ADD CONSTRAINT FK_TABELA_MD_TABELA FOREIGN KEY (TABELA) REFERENCES MD_TABELA (HANDLE)';
      vCommand.Execute();
    end;
  finally
    vCommand.Free;
    vQuery.Free;
  end;
end;

procedure TMDScript.ExecuteMD_STATUS;
const
  vTabela: string = 'MD_STATUS';
begin
  CriarTabela(vTabela, 'Status do registro', 'Status de tabela');

  CriarCampo(vTabela, 'DESCRICAO', 'VARCHAR(50)', 'Descrição');

  InserirRegistro(vTabela, 'DESCRICAO', 'Cadastrado');
  InserirRegistro(vTabela, 'DESCRICAO', 'Encerrado');
  InserirRegistro(vTabela, 'DESCRICAO', 'Ativo');
  InserirRegistro(vTabela, 'DESCRICAO', 'Cancelado');
  InserirRegistro(vTabela, 'DESCRICAO', 'Em execução');
  InserirRegistro(vTabela, 'DESCRICAO', 'Ag modificação');
end;

initialization
  RegisterClass(TMDScript);

end.
