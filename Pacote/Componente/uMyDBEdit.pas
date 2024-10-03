unit uMyDBEdit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.DBCtrls, Data.DB,
  Vcl.Graphics, Winapi.Windows, System.Generics.Collections,

  uMyQuery;

type
  TMyDBEdit = class(TDBEdit)
  private
    FTitulo: string;
    FReadOnly: Boolean;
    FForcarReadOnly: Boolean;
    FWidthPercentual: Integer;

    FDataSource: TDataSource;
    FLblTitulo: TLabel;

    FListaOnAlterar: TList<TNotifyEvent>;

    procedure SetTitulo(prValor: string);
    procedure setReadOnly(prValor: Boolean);
    procedure setDataSource(prValor: TDataSource);
    procedure FormatarCampo();

    //--Eventos
    procedure AfterOpenQueryPrincipal(prDataSet: TDataSet);
    procedure AfterInsertQueryPrincipal(prDataSet: TDataSet);
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure DoExit; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddOnChange(prEvent: TNotifyEvent);

    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); override;
    procedure AfterConstruction; override;
  published
    property WidthPercentual: Integer read FWidthPercentual write FWidthPercentual;
    property Titulo: string read FTitulo write SetTitulo;
    property ReadOnly: Boolean read FReadOnly write setReadOnly;
    property ForcarReadOnly: Boolean read FForcarReadOnly write FForcarReadOnly;
    property DataSource read FDataSource write setDataSource;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('My Components', [TMyDBEdit]);
end;

{ TMyDBEdit }

procedure TMyDBEdit.AddOnChange(prEvent: TNotifyEvent);
begin
  FListaOnAlterar.Add(prEvent);
end;

procedure TMyDBEdit.AfterConstruction;
begin
  inherited;

  //
end;

procedure TMyDBEdit.AfterInsertQueryPrincipal(prDataSet: TDataSet);
begin
  FormatarCampo();
end;

procedure TMyDBEdit.AfterOpenQueryPrincipal(prDataSet: TDataSet);
begin
  FormatarCampo();
end;

constructor TMyDBEdit.Create(AOwner: TComponent);
begin
  inherited;

  FLblTitulo := TLabel.Create(nil);
  FListaOnAlterar := TList<TNotifyEvent>.Create;

  Self.StyleElements := [seClient, seBorder];
end;

destructor TMyDBEdit.Destroy;
begin
  if FLblTitulo <> nil then
    FLblTitulo.Free;

  if FListaOnAlterar <> nil then
    FreeAndNil(FListaOnAlterar);

  inherited;
end;

procedure TMyDBEdit.DoExit;
var
  vProc: TNotifyEvent;
begin
  inherited;

  if FDataSource.DataSet.State in [dsInsert, dsEdit] then
  begin
    for vProc in FListaOnAlterar do
      vProc(nil);
  end;
end;

procedure TMyDBEdit.FormatarCampo;
var
  vField: TField;
begin
  vField := Self.DataSource.DataSet.FieldByName(Self.DataField);

  case vField.DataType of

    ftFloat, ftCurrency, ftBCD:
      TNumericField(vField).DisplayFormat := '###,###,##0.00';

    ftDateTime:
    begin
      TDateTimeField(vField).DisplayFormat := 'dd/MM/yyyy HH:mm';
    end;

    ftDate:
    begin
      TDateField(vField).DisplayFormat := 'dd/MM/yyyy';
    end;
  end;
end;

procedure TMyDBEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if Key = VK_F4 then
  begin
    if FDataSource.DataSet.State in [dsInsert, dsEdit] then
      FDataSource.DataSet.FieldByName(Self.DataField).AsDateTime := StrToDateTime(FormatDateTime('dd/mm/yyyy hh:mm', Now()));
  end;
end;

procedure TMyDBEdit.KeyPress(var Key: Char);
begin
  inherited;

  if Key = #13 then
  begin
    Key := #0;
    keybd_event(VK_TAB, 0, KEYEVENTF_EXTENDEDKEY, 0);
  end;
end;

procedure TMyDBEdit.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;

  if Assigned(FLblTitulo) then
  begin
    if (FLblTitulo.Parent = nil) and (Self.Parent <> nil) then
      FLblTitulo.Parent := Self.Parent;

    FLblTitulo.Left := ALeft;
    FLblTitulo.Top := ATop - 14;
  end;
end;

procedure TMyDBEdit.setDataSource(prValor: TDataSource);
begin
  inherited DataSource := prValor;

  FDataSource := prValor;
  TMyQuery(FDataSource.DataSet).AddAfterOpen(AfterOpenQueryPrincipal);
  TMyQuery(FDataSource.DataSet).AddAfterInsert(AfterInsertQueryPrincipal);
end;

procedure TMyDBEdit.setReadOnly(prValor: Boolean);
begin
  if FForcarReadOnly then
  begin
    inherited ReadOnly := True;
    FReadOnly := True;
  end
  else begin
   inherited ReadOnly := prValor;
   FReadOnly := prValor;
  end;

  if FReadOnly then
    Self.Font.Color := clGray
  else
    Self.Font.Color := clBlack;
end;

procedure TMyDBEdit.SetTitulo(prValor: string);
begin
  FTitulo := prValor;
  Self.FLblTitulo.Caption := prValor;
end;

end.
