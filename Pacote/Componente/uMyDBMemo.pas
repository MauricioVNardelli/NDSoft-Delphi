 unit uMyDBMemo;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, Vcl.DBCtrls,
  Vcl.Graphics, Winapi.Windows;

type
  TMyDBMemo = class(TDBMemo)
  private
    FTitulo: string;
    FReadOnly: Boolean;

    FLblTitulo: TLabel;

    procedure SetTitulo(prValor: string);
    procedure setReadOnly(prValor: Boolean);

    procedure OnKeyPressMyEdit(Sender: TObject; var prKey: Char);
  protected
    { Protected declarations }
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); override;
  published
    property Titulo: string read FTitulo write SetTitulo;
    property ReadOnly read FReadOnly write setReadOnly;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('My Components', [TMyDBMemo]);
end;

{ TMyDBMemo }

constructor TMyDBMemo.Create(AOwner: TComponent);
begin
  inherited;

  FLblTitulo := TLabel.Create(nil);

  Self.StyleElements := [seClient, seBorder];
  OnKeyPress := Self.OnKeyPressMyEdit;
end;

destructor TMyDBMemo.Destroy;
begin
  if FLblTitulo <> nil then
    FLblTitulo.Free;

  inherited;
end;

procedure TMyDBMemo.OnKeyPressMyEdit(Sender: TObject; var prKey: Char);
begin
  if prKey = #13 then
  begin
    prKey := #0;
    keybd_event(VK_TAB, 0, KEYEVENTF_EXTENDEDKEY, 0);
  end;
end;

procedure TMyDBMemo.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
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

procedure TMyDBMemo.setReadOnly(prValor: Boolean);
begin
  inherited ReadOnly := prValor;
  FReadOnly := prValor;

  if prValor then
    Self.Font.Color := clGray

  else if Self.DataField <> 'HANDLE' then
    Self.Font.Color := clBlack;
end;

procedure TMyDBMemo.SetTitulo(prValor: string);
begin
  FTitulo := prValor;
  Self.FLblTitulo.Caption := prValor;
end;

end.
