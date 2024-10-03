unit uFormModelo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Data.Win.ADODB, Data.DB,
  Vcl.ComCtrls, Vcl.Mask, Vcl.DBCtrls,
  //
  uSistema, uMyDBEdit, uMyComboBox, uMyDBMemo, uMyMaskEdit, uMyQuery;

type
  TformModelo = class(TForm)
    btnFechar: TButton;
    btnGravarEditar: TButton;
    pnlPrincipal: TPanel;
    tcPrincipal: TPageControl;
    pnlSuperior: TPanel;
    edtCodigo: TMyDBEdit;

    procedure btnFecharClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FQuery: TMyQuery;
    FDataSource: TDataSource;

    FListaMyDBEdit: array of TMyDBEdit;
    FListaMyComboBox: array of TMyComboBox;
    FListaMyDBMemo: array of TMyDBMemo;
    FListaMyMaskEdit: array of TMyMaskEdit;

    FHandle: Integer;
    FTabela: string;

    procedure ConfigurarComponente();
    procedure ConfigurarFormulario();

    procedure btnGravarOnClick(Sender: TObject);
    procedure btnEditarOnClick(Sender: TObject);
  protected
    procedure GravarOnClick(); virtual;
    procedure EditarOnClick(); virtual;

    property Query: TMyQuery read FQuery;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetHandle(prValor: Integer);

    property Handle: Integer read FHandle write SetHandle;
  end;

var
  formModelo: TformModelo;

implementation

{$R *.dfm}

procedure TformModelo.btnEditarOnClick(Sender: TObject);
begin
  FQuery.Edit;

  ConfigurarFormulario();
  ConfigurarComponente();

  //--
  EditarOnClick();
end;

procedure TformModelo.btnFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TformModelo.btnGravarOnClick(Sender: TObject);
begin
  FQuery.Post;

  ConfigurarFormulario();
  ConfigurarComponente();

  //--
  GravarOnClick();
end;

procedure TformModelo.ConfigurarFormulario;
begin
  if FQuery.State = dsBrowse then
  begin
    btnGravarEditar.Caption := 'Editar';
    btnGravarEditar.OnClick := btnEditarOnClick;

  end else
  if FQuery.State in [dsInsert, dsEdit] then
  begin
    btnGravarEditar.Caption := 'Gravar';
    btnGravarEditar.OnClick := btnGravarOnClick;
  end;
end;

constructor TformModelo.Create(AOwner: TComponent);
var
  vIndex: Integer;
  vIndexLista: Integer;
begin
  inherited;

  FTabela := StringReplace(Self.Name, 'Form', '', [rfReplaceAll, rfIgnoreCase]);

  FQuery := TMyQuery.Create(nil);

  FDataSource := TDataSource.Create(nil);
  FDataSource.DataSet := FQuery;

  for vIndex := 0 to ComponentCount - 1 do
  begin
    if Components[vIndex] is TMyDBEdit then
    begin
      SetLength(FListaMyDBEdit, Length(FListaMyDBEdit) + 1);
      vIndexLista := Length(FListaMyDBEdit) - 1;

      FListaMyDBEdit[vIndexLista] := TMyDBEdit(Components[vIndex]);
      FListaMyDBEdit[vIndexLista].DataSource := FDataSource;
    end else

    if Components[vIndex] is TMyComboBox then
    begin
      SetLength(FListaMyComboBox, Length(FListaMyComboBox) + 1);
      vIndexLista := Length(FListaMyComboBox) - 1;

      FListaMyComboBox[vIndexLista] := TMyComboBox(Components[vIndex]);
      FListaMyComboBox[vIndexLista].DataSet := FQuery;
      FListaMyComboBox[vIndexLista].OnCreateFormModelo;
    end else

    if Components[vIndex] is TMyDBMemo then
    begin
      SetLength(FListaMyDBMemo, Length(FListaMyDBMemo) + 1);
      vIndexLista := Length(FListaMyDBMemo) - 1;

      FListaMyDBMemo[vIndexLista] := TMyDBMemo(Components[vIndex]);
      FListaMyDBMemo[vIndexLista].DataSource := FDataSource;
    end else

    if Components[vIndex] is TMyMaskEdit then
    begin
      SetLength(FListaMyMaskEdit, Length(FListaMyMaskEdit) + 1);
      vIndexLista := Length(FListaMyMaskEdit) - 1;

      FListaMyMaskEdit[vIndexLista] := TMyMaskEdit(Components[vIndex]);
      FListaMyMaskEdit[vIndexLista].DataSource := FDataSource;
    end;
  end;
end;

destructor TformModelo.Destroy;
begin
  if FQuery <> nil then
    FreeAndNil(FQuery);

  inherited;
end;

procedure TformModelo.EditarOnClick;
begin
  //
end;

procedure TformModelo.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Self.btnFechar.Click();
end;

procedure TformModelo.GravarOnClick;
begin
  //Implementando nas classes filhas
end;

procedure TformModelo.SetHandle(prValor: Integer);
var
  vQuery: TADOQuery;
begin
  vQuery := TADOQuery.Create(nil);
  try
    vQuery.Connection := Sistema.GetConexao();
    vQuery.SQL.Text := ' SELECT MAX(HANDLE) HANDLE FROM ' + FTabela;
    vQuery.Active := True;

    FQuery.Active := False;
    FQuery.SQL.Text := ' SELECT * FROM ' + FTabela + ' WHERE HANDLE = ' + IntToStr(prValor);
    FQuery.Active := True;

    if prValor <= 0 then
    begin
      FQuery.Insert();
      FQuery.FieldByName('HANDLE').AsInteger := vQuery.FieldByName('HANDLE').AsInteger + 1;
    end;

    ConfigurarComponente();
    ConfigurarFormulario();
  finally
    vQuery.Free;
  end;
end;

procedure TformModelo.ConfigurarComponente();
var
  vIndex: Integer;

  vMyEdit: TMyDBEdit;
  vMyDBMemo: TMyDBMemo;
  vMyComboBox: TMyComboBox;
  vMyMaskEdit: TMyMaskEdit;
begin
  for vIndex := 0 to Length(FListaMyDBEdit) - 1 do
  begin
    vMyEdit := FListaMyDBEdit[vIndex];

    if vMyEdit.DataField <> 'HANDLE' then
      vMyEdit.ReadOnly := not (FQuery.State in [dsInsert, dsEdit])
    else
      vMyEdit.ReadOnly := True;
  end;

  for vIndex := 0 to Length(FListaMyComboBox) - 1 do
  begin
    vMyComboBox := FListaMyComboBox[vIndex];
    vMyComboBox.Enabled := (FQuery.State in [dsInsert, dsEdit]);
  end;

  for vIndex := 0 to Length(FListaMyDBMemo) - 1 do
  begin
    vMyDBMemo := FListaMyDBMemo[vIndex];
    vMyDBMemo.ReadOnly := not (FQuery.State in [dsInsert, dsEdit]);
  end;

  for vIndex := 0 to Length(FListaMyMaskEdit) - 1 do
  begin
    vMyMaskEdit := FListaMyMaskEdit[vIndex];
    vMyMaskEdit.ReadOnly := not (FQuery.State in [dsInsert, dsEdit]);
  end;
end;

end.
