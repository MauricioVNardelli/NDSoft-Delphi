unit uFormGerenciamento;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls,
  Data.Win.ADODB, System.UITypes,
  //
  uSistema, uMyQuery, uFormModelo;

type
  TformGerenciamento = class(TForm)
    dbPrincipal: TDBGrid;
    pnlBotoes: TPanel;
    pnlRodape: TPanel;
    btnFechar: TButton;
    pnlTitulo: TPanel;
    lblTitulo: TLabel;
    btnExcluir: TButton;
    btnInserir: TButton;

    procedure btnFecharClick(Sender: TObject);
    procedure btnInserirClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
  private
    FTabela: string;

    FQuery: TADOQuery;
    FDataSource: TDataSource;

    procedure setTabela(prTabela: string);
    procedure OnAfterOpenQuery(prDataSet: TDataSet);
    procedure ConfigurarFormulario();
    procedure AbrirFormulario(prHandle: Integer);

    //Eventos
    procedure OnDblClickDbGrid(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Tabela: string write setTabela;
  end;

var
  formGerenciamento: TformGerenciamento;

implementation

{$R *.dfm}

procedure TformGerenciamento.AbrirFormulario(prHandle: Integer);
var
  vFormClass: TFormClass;
  myClassFinder: TClassFinder;

  vFormulario: TformModelo;
begin
  if prHandle <> 0 then
  begin
    myClassFinder := TClassFinder.Create(TForm, False);
    try
      vFormClass := TFormClass(myClassFinder.GetClass('TForm' + FTabela));

      if vFormClass = nil then
        raise Exception.Create('Formulário da tabela não encontrada' + sLineBreak +
                               'Tabela: ' + FTabela);
    finally
      myClassFinder.Free;
    end;

    vFormulario := TformModelo(vFormClass.Create(nil));
    try
      vFormulario.SetHandle(prHandle);
      vFormulario.ShowModal();
    finally
      FreeAndNil(vFormulario);

      FQuery.Active := False;
      FQuery.Active := True;
    end;
  end;
end;

procedure TformGerenciamento.btnExcluirClick(Sender: TObject);
begin
  if MessageDlg('Deseja realmente excluir o registro selecionado?', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    FQuery.Delete();

    ConfigurarFormulario();
  end;
end;

procedure TformGerenciamento.btnFecharClick(Sender: TObject);
begin
  Self.Close();

  if FQuery <> nil then
    FreeAndNil(FQuery);
end;

procedure TformGerenciamento.btnInserirClick(Sender: TObject);
begin
  AbrirFormulario(-1);
end;

procedure TformGerenciamento.ConfigurarFormulario;
begin
  btnExcluir.Enabled := FQuery.RecordCount > 0;
end;

constructor TformGerenciamento.Create(AOwner: TComponent);
begin
  inherited;

  FQuery := TADOQuery.Create(nil);
  FDataSource := TDataSource.Create(FQuery);

  FQuery.Connection := Sistema.GetConexao();
  FDataSource.DataSet := FQuery;
  FDataSource.AutoEdit := False;

  dbPrincipal.DataSource := FDataSource;
  dbPrincipal.OnDblClick := OnDblClickDbGrid;
  dbPrincipal.ReadOnly := True;

  FQuery.AfterOpen := OnAfterOpenQuery;
end;

destructor TformGerenciamento.Destroy;
begin
  if FQuery <> nil then
    FreeAndNil(FQuery);

  inherited;
end;

procedure TformGerenciamento.OnAfterOpenQuery(prDataSet: TDataSet);
var
  vIndex: Integer;
  vKey: string;
begin
  for vIndex := 0 to dbPrincipal.Columns.Count - 1 do
  begin
    vKey := FTabela + '|' + dbPrincipal.Columns[vIndex].FieldName;

    dbPrincipal.Columns[vIndex].Title.Caption := Sistema.GetDescricaoMD_CAMPO(vKey);
  end;
end;

procedure TformGerenciamento.OnDblClickDbGrid(Sender: TObject);
begin
  AbrirFormulario(FQuery.FieldByName('HANDLE').AsInteger);
end;

procedure TformGerenciamento.setTabela(prTabela: string);
var
  vIndex: Integer;
  vDescricao, vTitulo: String;
begin
  FTabela := prTabela;

  FQuery.Active := False;
  FQuery.SQL.Text := 'SELECT DESCRICAOGERENCIAMENTO FROM MD_TABELA WHERE NOME = :NOME';
  FQuery.Parameters.ParamByName('NOME').Value := prTabela;
  FQuery.Active := True;

  vTitulo := '';
  vDescricao := FQuery.FieldByName('DESCRICAOGERENCIAMENTO').AsString;

  for vIndex := 1 to Length(vDescricao) do
    vTitulo := vTitulo + vDescricao[vIndex] + sLineBreak;

  lblTitulo.Caption := vTitulo;

  FQuery.Active := False;
  FQuery.SQL.Text := 'SELECT * FROM ' + prTabela + ' ORDER BY HANDLE DESC ';
  FQuery.Active := True;

  ConfigurarFormulario();
end;

end.
