unit uMyMaskEdit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Mask, Data.DB, Winapi.Windows, Vcl.Graphics, Math,
  Vcl.ComCtrls, Vcl.Forms, Vcl.Buttons, System.DateUtils, System.Generics.Collections,

  uMyQuery;

type
  TMyTypeMask = (myString, myDate, myDateTime, myNumeric);

  TMyMaskEdit = class(TCustomMaskEdit)
  private
    FCampo: string;
    FTitulo: string;
    FReadOnly: Boolean;

    FListaOnAlterar: TList<TNotifyEvent>;

    FLblTitulo: TLabel;
    FQuery: TMyQuery;
    FDataSource: TDataSource;
    FTipoMascara: TMyTypeMask;

    FBtnCalendario: TSpeedButton;

    procedure SetTitulo(const prValor: string);
    procedure setReadOnly(const prValor: Boolean);
    procedure SetDataSource(const prValor: TDataSource);
    procedure SetTipoMascara(const prValor: TMyTypeMask);

    procedure AfterOpenQueryPrincipal(prDataSet: TDataSet);
    procedure BeforePostQueryPrincipal(prDataSet: TDataSet);

    procedure BotaoCalendarioOnClick(Sender: TObject);
    procedure OnDblCalendarioClick(Sender: TObject);
    procedure OnKeyPressCalendario(Sender: TObject; var Key: Char);
    procedure EditOnExit(Sender: TObject);

    procedure OnMyKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  public
    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); override;
    procedure AddOnChange(prEvent: TNotifyEvent);

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    //--Propriedade
    property EditMask;
    property ReadOnly read FReadOnly write setReadOnly;
    property Titulo: string read FTitulo write SetTitulo;
    property Campo: string read FCampo write FCampo;
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property TipoMascara: TMyTypeMask read FTipoMascara write SetTipoMascara;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('My Components', [TMyMaskEdit]);
end;

{ TMyMaskEdit }

procedure TMyMaskEdit.AddOnChange(prEvent: TNotifyEvent);
begin
  FListaOnAlterar.Add(prEvent);
end;

procedure TMyMaskEdit.AfterOpenQueryPrincipal(prDataSet: TDataSet);
begin
  case Self.FTipoMascara of
    myNumeric: Self.Text := FormatFloat('#,##0.00', FQuery.FieldByName(FCampo).AsFloat);
  else
    Self.Text := FQuery.FieldByName(FCampo).AsString;
  end;
end;

procedure TMyMaskEdit.BeforePostQueryPrincipal(prDataSet: TDataSet);
begin
  //
end;

procedure TMyMaskEdit.BotaoCalendarioOnClick(Sender: TObject);
var
  vData: TDateTime;
  vFormCalendar: TForm;
  vCalendario: TMonthCalendar;
begin
  vFormCalendar := TForm.Create(Self);
  vCalendario := TMonthCalendar.Create(vFormCalendar);
  try
    vFormCalendar.BorderStyle := bsDialog;
    vFormCalendar.Width := 200;
    vFormCalendar.Height := 200;
    vFormCalendar.Position := poDesktopCenter;
    vFormCalendar.Caption := Self.Titulo;
    vFormCalendar.OnKeyPress := OnKeyPressCalendario;

    vCalendario.StyleElements := [];
    vCalendario.Parent := vFormCalendar;
    vCalendario.Align := alClient;
    vCalendario.AutoSize := True;
    vCalendario.OnDblClick := OnDblCalendarioClick;

    if vFormCalendar.ShowModal > 0 then
    begin
      vData := vCalendario.Date;

      if DataSource.DataSet.State <> dsEdit then
        DataSource.DataSet.Edit;

      vData := EncodeDateTime(YearOf(vData), MonthOf(vData), DayOf(vData), HourOf(Now), MinuteOf(Now), 0, 0);

      DataSource.DataSet.FieldByName(FCampo).AsDateTime := vData;
      Self.Text := FormatDateTime('dd/MM/yyyy HH:mm', vData);
    end;
  finally
    vFormCalendar.Free;
  end;
end;

constructor TMyMaskEdit.Create(AOwner: TComponent);
begin
  inherited;

  FLblTitulo := TLabel.Create(nil);
  FListaOnAlterar := TList<TNotifyEvent>.Create;

  Self.StyleElements := [seClient, seBorder];
  Self.OnKeyDown := OnMyKeyDown;
  Self.OnExit := EditOnExit;

  FBtnCalendario := TSpeedButton.Create(nil);
  FBtnCalendario.Parent := Self;
  FBtnCalendario.Width := 20;
  FBtnCalendario.StyleElements := [];
  FBtnCalendario.Flat := True;
  FBtnCalendario.Align := alRight;
  FBtnCalendario.Caption := '▼';
  FBtnCalendario.OnClick := Self.BotaoCalendarioOnClick;
  //FBtnCalendario.Glyph.LoadFromFile(ExtractFileDir(Application.ExeName) + '\src\edit_calendar.bmp');
  FBtnCalendario.Cursor := crArrow;
end;

destructor TMyMaskEdit.Destroy;
begin
  if FLblTitulo <> nil then
    FLblTitulo.Free;

  if FBtnCalendario <> nil then
    FreeAndNil(FBtnCalendario);

  if FListaOnAlterar <> nil then
    FreeAndNil(FListaOnAlterar);

  inherited;
end;

procedure TMyMaskEdit.EditOnExit(Sender: TObject);
var
  vProc: TNotifyEvent;
  vData: TDateTime;
  vDia: Integer;
  vMes: Integer;
  vAno: Integer;
  vHora: Integer;
  vMinuto: Integer;
  vAnoStr: string;
begin
  inherited;

  if Trim(StringReplace(StringReplace(Self.Text, '/', '', [rfReplaceAll]), ':', '', [rfReplaceAll])) <> '' then
  begin
    if FQuery.State in [dsInsert, dsEdit] then
    begin
      vDia := StrToInt(Copy(Self.Text, 1, 2));

      if Trim(Copy(Self.Text, 4, 2)) <> '' then
        vMes := StrToInt(StringReplace(Copy(Self.Text, 4, 2), ' ', '', [rfReplaceAll]))
      else
        vMes := MonthOf(Now());

      if Trim(Copy(Self.Text, 7, 4)) <> '' then
      begin
        vAnoStr := StringReplace(Copy(Self.Text, 7, 4), ' ', '', [rfReplaceAll]);

        if Length(vAnoStr) = 2 then
          vAnoStr := Copy(IntToStr(YearOf(Now())), 1, 2) + vAnoStr;

        vAno := StrToInt(vAnoStr);
      end
      else
        vAno := YearOf(Now());

      if Trim(Copy(Self.Text, Pos(':', Self.Text) - 2, 2)) <> '' then
        vHora := StrToInt(Copy(Self.Text, Pos(':', Self.Text) - 2, 2))
      else
        vHora := HourOf(Now());

      if Trim(Copy(Self.Text, Pos(':', Self.Text) + 1, 2)) <> '' then
        vMinuto := StrToInt(Copy(Self.Text, Pos(':', Self.Text) + 1, 2))
      else
        vMinuto := MinuteOf(Now());

      vData := EncodeDateTime(vAno, vMes, vDia, vHora, vMinuto, 0, 0);
      Self.Text := DateTimeToStr(vData);

      if Self.Text = '' then
        FQuery.FieldByName(FCampo).AsFloat := 0

      else
      if FQuery.FieldByName(FCampo).DataType = ftDateTime then
        FQuery.FieldByName(FCampo).AsDateTime := vData;

      if FDataSource.DataSet.State in [dsInsert, dsEdit] then
      begin
        for vProc in FListaOnAlterar do
          vProc(nil);
      end;
    end;

  end;
end;

procedure TMyMaskEdit.OnDblCalendarioClick(Sender: TObject);
begin
  TForm(TMonthCalendar(Sender).Parent).Close;
end;

procedure TMyMaskEdit.OnKeyPressCalendario(Sender: TObject; var Key: Char);
begin
  if key = #$1B then
    TForm(Sender).Close;
end;

procedure TMyMaskEdit.OnMyKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  inherited;

  if Key = VK_F4 then
    Self.Text := DateToStr(Date);
end;

procedure TMyMaskEdit.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
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

procedure TMyMaskEdit.SetDataSource(const prValor: TDataSource);
begin
  FDataSource := prValor;

  FQuery := TMyQuery(FDataSource.DataSet);
  FQuery.AddBeforePost(BeforePostQueryPrincipal);
  FQuery.AddAfterOpen(AfterOpenQueryPrincipal);
end;

procedure TMyMaskEdit.setReadOnly(const prValor: Boolean);
begin
  inherited ReadOnly := prValor;
  FReadOnly := prValor;
  FBtnCalendario.Enabled := not FReadOnly;

  if prValor then
    Self.Font.Color := clGray
  else
    Self.Font.Color := clBlack;
end;

procedure TMyMaskEdit.SetTipoMascara(const prValor: TMyTypeMask);
begin
  FTipoMascara := prValor;

  case prValor of

    myDate:
    begin
      Self.EditMask := '##/##/####';
      Self.Width := 65;
    end;

    myDateTime:
    begin
      Self.EditMask := '##/##/#### ##:##';
      Self.Width := 100;
    end;

    myNumeric:
    begin
      if Self.Text = '' then
        Self.Text := '0,00';

      Self.Alignment := taRightJustify;
    end;
  end;

end;

procedure TMyMaskEdit.SetTitulo(const prValor: string);
begin
  FTitulo := prValor;
  Self.FLblTitulo.Caption := prValor;
end;

end.
