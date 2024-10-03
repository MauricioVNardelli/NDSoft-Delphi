unit uMyEditFiltro;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Mask, Data.DB, Winapi.Windows;

type
  TMyEditFiltro = class(TMaskEdit)
  private
    FFieldType: TFieldType;

    procedure SetFieldType(prValue: TFieldType);
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoExit; override;
  public
     { Public declarations }
  published
    property FieldType: TFieldType read FFieldType write SetFieldType;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('My Components', [TMyEditFiltro]);
end;

{ TMyEditFiltro }

procedure TMyEditFiltro.DoExit;
begin
  inherited;

  if (FFieldType in [ftCurrency, ftBCD, ftFloat]) and (Self.Text <> '') then
    Self.Text := FormatFloat('#,##0.00', StrToFloat(Self.Text));
end;

procedure TMyEditFiltro.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if (Key = VK_F4) and (FFieldType in [ftDate, ftDateTime]) then
    Self.Text := DateToStr(Date);
end;

procedure TMyEditFiltro.SetFieldType(prValue: TFieldType);
begin
  FFieldType := prValue;

  case prValue of
    ftFloat, ftCurrency, ftBCD: Self.Alignment := taRightJustify;
    ftDateTime: Self.EditMask := '!99/99/0000 00:00;1;_';
    ftDate: Self.EditMask := '!99/99/0000;1;_';
  end;
end;

end.
