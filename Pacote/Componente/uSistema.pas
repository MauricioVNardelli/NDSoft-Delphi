unit uSistema;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.IniFiles, Data.Win.ADODB,
  System.Generics.Collections, Vcl.Forms,

  uScriptBase;

type
  TSistema = class(TObject)
  strict private
    class var FInstance: TSistema;
  private
    FConexao: TADOConnection;
    FListaMD_CAMPO: TDictionary<string, string>;
  public
    FDll: array of THandle;
    FListaModulo: TList<string>;

    class function GetInstance(): TSistema;

    constructor Create();

    procedure CarregarDll();
    procedure AnalisarTabela();

    function GetConexao(): TADOConnection;
    function GetDescricaoMD_CAMPO(prValor: string): string;
    function GetHandle(const prTabela, prCampo: string; prValor: Variant): Integer;
    function NovoHandle(const prTabela: string): Integer;

    destructor Destroy; override;
  end;

var
  Sistema: TSistema;

implementation

{ TSistema }

procedure TSistema.AnalisarTabela;
var
  vIndex: Integer;
  vClassName: string;

  vScript: TScriptBase;
  vClasseTabela: TPersistentClass;
begin
  for vIndex := 0 to FListaModulo.Count - 1 do
  begin
    vClassName := 'T' + FListaModulo[vIndex] + 'Script';
    vClasseTabela := GetClass(vClassName);

    if vClasseTabela = nil then
      raise Exception.Create('Classe de script do módulo não encontrada' + sLineBreak +
                             'Módulo: ' + FListaModulo[vIndex]);

    vScript := TScriptBase(vClasseTabela.Create).Create;
    try
      vScript.Execute;
    finally
      FreeAndNil(vScript);
    end;
  end;
end;

procedure TSistema.CarregarDll;
begin
  SetLength(FDll, 3);

  FDll[0] := LoadLibrary('Metadados.dll');
  FListaModulo.Add('MD');

  FDll[1] := LoadLibrary('Fiscal.dll');
  FListaModulo.Add('FI');

  FDll[2] := LoadLibrary('Hotel.dll');
  FListaModulo.Add('HO');

  //if FDll[0] = 0 then
    //raise Exception.Create('Não foi possível carregar a biblioteca Tecnologia.dll.');
end;

constructor TSistema.Create;
begin
  FListaModulo := TList<string>.Create();;
end;

destructor TSistema.Destroy;
var
  vIndex: Integer;
begin
  FConexao.Free();
  FListaMD_CAMPO.Free();
  FListaModulo.Free();

  for vIndex := 0 to Length(FDll) - 1 do
    FreeLibrary(FDll[vIndex]);

  inherited;
end;

function TSistema.GetConexao: TADOConnection;
var
  vIniFile: TIniFile;
begin
  if not Assigned(Self.FConexao) then
  begin
    FConexao := TADOConnection.Create(nil);
    FConexao.LoginPrompt := False;

    vIniFile := TIniFile.Create(ExtractFileDir(Application.ExeName) + '\configuracao.ini');
    try
      if not FConexao.Connected then
      begin
        FConexao.ConnectionString := 'Application Name=NDSoft;' +
                                     'Provider=' + vIniFile.ReadString('CONFIGURACAO', 'PROVEDOR', '') + ';' +
                                     'Server=' + vIniFile.ReadString('CONFIGURACAO', 'SERVIDORBANCO', '') + ';' +
                                     'Database=' + vIniFile.ReadString('CONFIGURACAO', 'BANCO', '') + ';' +
                                     'Uid=' + vIniFile.ReadString('CONFIGURACAO', 'USUARIO', '') + ';' +
                                     'Password=' + vIniFile.ReadString('CONFIGURACAO', 'SENHA', '') + ';';
        FConexao.Connected := True;
      end;
    finally
      vIniFile.Free();
    end;
  end;

  Result := Self.FConexao;
end;

class function TSistema.GetInstance: TSistema;
begin
  if not Assigned(Self.FInstance) then
    Self.FInstance := TSistema.Create;

  Result := Self.FInstance;
end;

function TSistema.NovoHandle(const prTabela: string): Integer;
var
  vQuery: TADOQuery;
begin
  vQuery := TADOQuery.Create(nil);
  try
    vQuery.Connection := GetConexao();

    vQuery.SQL.Text := 'SELECT MAX(HANDLE) HANDLE ' +
                       '  FROM ' + prTabela;
    vQuery.Active := True;

    Result := vQuery.FieldByName('HANDLE').AsInteger + 1;
  finally
    vQuery.Free;
  end;
end;

function TSistema.GetDescricaoMD_CAMPO(prValor: string): string;
var
  vKey: string;
  vQuery: TADOQuery;
begin
  if FListaMD_CAMPO = nil then
  begin
    FListaMD_CAMPO := TDictionary<string, string>.Create;

    vQuery := TADOQuery.Create(nil);
    try
      vQuery.Connection := GetConexao();

      vQuery.SQL.Text := ' SELECT A.NOME NOMETABELA, ' +
                         '        B.NOME NOMECAMPO, ' +
                         '        B.DESCRICAO ' +
                         '   FROM MD_TABELA A ' +
                         '  INNER JOIN MD_CAMPO B ON B.TABELA = A.HANDLE ';
      vQuery.Active := True;

      while not vQuery.Eof do
      begin
        vKey := vQuery.FieldByName('NOMETABELA').AsString + '|' + vQuery.FieldByName('NOMECAMPO').AsString;
        FListaMD_CAMPO.Add(vKey, vQuery.FieldByName('DESCRICAO').AsString);

        vQuery.Next();
      end;
    finally
      vQuery.Free;
    end;
  end;

  FListaMD_CAMPO.TryGetValue(prValor, Result);
end;

function TSistema.GetHandle(const prTabela, prCampo: string; prValor: Variant): Integer;
var
  vQuery: TADOQuery;
begin
  vQuery := TADOQuery.Create(nil);
  try
    vQuery.Connection := GetConexao();

    vQuery.SQL.Text := 'SELECT HANDLE ' +
                       '  FROM ' + prTabela +
                       ' WHERE ' + prCampo + ' = :VALOR ';
    vQuery.Parameters.ParamByName('VALOR').Value := prValor;
    vQuery.Active := True;

    Result := vQuery.FieldByName('HANDLE').AsInteger;
  finally
    vQuery.Free;
  end;
end;

end.
