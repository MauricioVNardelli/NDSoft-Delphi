unit uMyComboBox;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.DBCtrls, Vcl.StdCtrls, Data.DB, Forms, Winapi.Windows,
  System.Generics.Collections, Vcl.Buttons, Vcl.Graphics,

  uMyQuery, uMyComboBoxConsulta;

type
  TMyComboBox = class(TEdit)
  private
    FLblTitulo: TLabel;
    FDataSet: TMyQuery;

    FTitulo: string;
    FTabela: string;
    FCampo: string;
    FCampoFK: string;
    FReadOnly: Boolean;

    FListaIndiceHandle: TDictionary<Integer, Integer>;
    FListaHandleIndice: TDictionary<Integer, Integer>;

    FBtnConsulta: TSpeedButton;

    procedure AbrirFormularioConsulta();

    procedure SetTitulo(prValor: string);
    procedure SetDataSet(prValor: TMyQuery);
    procedure setReadOnly(prValor: Boolean);

    procedure AfterOpenQueryPrincipal(prDataSet: TDataSet);
    procedure BotaoConsultaOnClick(Sender: TObject);
  protected
    procedure DoExit; override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
     //
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); override;
    property ReadOnly: Boolean read FReadOnly write setReadOnly;
  published
    property Titulo: string read FTitulo write SetTitulo;
    property Tabela: string read FTabela write FTabela;
    property Campo: string read FCampo write FCampo;
    property CampoFK: string read FCampoFK write FCampoFK;
    property DataSet: TMyQuery read FDataSet write SetDataSet;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('My Components', [TMyComboBox]);
end;

{ TMyComboBox }

procedure TMyComboBox.AbrirFormularioConsulta;
var
  vConsulta: TFormMyComboBoxConsulta;
begin
  inherited;

  vConsulta := TFormMyComboBoxConsulta.CreateNew(nil);
  try
    vConsulta.SetInformacao(FTabela, FCampo, Self.Text);
    vConsulta.Caption := Self.FLblTitulo.Caption;
    vConsulta.ShowModal();

    if FDataSet.State in [dsInsert, dsEdit] then
    begin
      Self.Text := vConsulta.Valor;
      FDataSet.FieldByName(FCampoFK).AsInteger := vConsulta.Handle;
    end;
  finally
    vConsulta.Free;
  end;
end;

procedure TMyComboBox.AfterOpenQueryPrincipal(prDataSet: TDataSet);
var
  vQuery: TMyQuery;
begin
  vQuery := TMyQuery.Create(nil);
  try
    vQuery.SQL.Text := ' SELECT ' + FCampo +
                       '   FROM ' + FTabela +
                       '  WHERE HANDLE = ' + IntToStr(FDataSet.FieldByName(FCampoFK).AsInteger);
    vQuery.Active := True;

    Self.Text := vQuery.FieldByName(FCampo).AsString;
  finally
    vQuery.Free;
  end;
end;

procedure TMyComboBox.BotaoConsultaOnClick(Sender: TObject);
begin
  AbrirFormularioConsulta;
end;

constructor TMyComboBox.Create(AOwner: TComponent);
begin
  inherited;

  FListaIndiceHandle := TDictionary<Integer, Integer>.Create;
  FListaHandleIndice := TDictionary<Integer, Integer>.Create;

  FLblTitulo := TLabel.Create(Self);

  Self.StyleElements := [seClient, seBorder];
  Self.CharCase := TEditCharCase.ecUpperCase;

  FBtnConsulta := TSpeedButton.Create(nil);
  FBtnConsulta.Parent := Self;
  FBtnConsulta.Width := 20;
  FBtnConsulta.StyleElements := [];
  FBtnConsulta.Flat := True;
  FBtnConsulta.Align := alRight;
  FBtnConsulta.Caption := '▼';
  FBtnConsulta.OnClick := Self.BotaoConsultaOnClick;
  FBtnConsulta.Cursor := crArrow;
end;

destructor TMyComboBox.Destroy;
begin
  if FLblTitulo <> nil then
    FLblTitulo.Free;

  if FListaIndiceHandle <> nil then
    FListaIndiceHandle.Free;

  if FListaHandleIndice <> nil then
    FListaHandleIndice.Free;

  inherited;
end;

procedure TMyComboBox.DoExit;
var
  vQuery: TMyQuery;
begin
  inherited;

  if (FDataSet.State in [dsInsert, dsEdit]) and (Self.Text <> '') then
  begin
    vQuery := TMyQuery.Create(nil);
    try
      vQuery.SQL.Text := ' SELECT HANDLE ' + ', ' + FCampo +
                         '   FROM ' + FTabela +
                         '  WHERE ' + FCampo + ' LIKE :VALOR ' +
                         '    AND STATUS = 3 '; //Tinha que usar constantes...
      vQuery.Parameters.ParamByName('VALOR').Value := '%' + Self.Text + '%';
      vQuery.Active := True;

      if vQuery.RecordCount = 1 then
      begin
        Self.Text :=  vQuery.FieldByName(FCampo).AsString;
        FDataSet.FieldByName(FCampoFK).AsInteger := vQuery.FieldByName('HANDLE').AsInteger;
      end else
      if (vQuery.RecordCount > 1) then
        AbrirFormularioConsulta()
      else
      if vQuery.RecordCount = 0 then
        raise Exception.Create('Registro não encontrado!');
    finally
      vQuery.Free;
    end;
  end;
end;

procedure TMyComboBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if (Key = VK_F4) and (FDataSet.State in [dsInsert, dsEdit]) then
    AbrirFormularioConsulta();
end;

procedure TMyComboBox.KeyPress(var Key: Char);
begin
  inherited;

  if Key = #13 then
  begin
    Key := #0;
    keybd_event(VK_TAB, 0, KEYEVENTF_EXTENDEDKEY, 0);
  end;
end;

procedure TMyComboBox.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;

  if Assigned(FLblTitulo) then
  begin
    FLblTitulo.Left := ALeft;
    FLblTitulo.Top := ATop - 14;
  end;
end;

procedure TMyComboBox.SetDataSet(prValor: TMyQuery);
begin
  if Assigned(prValor) then
  begin
    FDataSet := prValor;

    FDataSet.AddAfterOpen(AfterOpenQueryPrincipal);
  end;
end;

procedure TMyComboBox.setReadOnly(prValor: Boolean);
begin
  inherited ReadOnly := prValor;
  FReadOnly := prValor;
  FBtnConsulta.Enabled := not FReadOnly;

  if FReadOnly then
    Self.Font.Color := clGray
  else
    Self.Font.Color := clBlack;
end;

procedure TMyComboBox.SetTitulo(prValor: string);
begin
  FTitulo := prValor;
  Self.FLblTitulo.Caption := prValor;

  if FLblTitulo.Parent <> Self.Parent then
    FLblTitulo.Parent := Self.Parent;
end;

end.
