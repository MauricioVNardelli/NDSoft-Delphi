unit uMyDateTime;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.DBCtrls, Vcl.StdCtrls, Data.DB, Forms, Winapi.Windows,
  System.Generics.Collections, Vcl.ComCtrls,

  uMyQuery;

type
  TMyDateTime = class(TDateTimePicker)
  private
    FLblTitulo: TLabel;
    FDataSet: TMyQuery;

    FTitulo: string;
    FCampo: string;

    procedure SetTitulo(prValor: string);
    procedure SetDataSet(prValor: TMyQuery);

    procedure AfterOpenQueryPrincipal(prDataSet: TDataSet);
    procedure BeforePostQueryPrincipal(prDataSet: TDataSet);
    procedure OnKeyPressMyEdit(Sender: TObject; var prKey: Char);
  protected
    //
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SetBounds(ALeft: Integer; ATop: Integer; AWidth: Integer; AHeight: Integer); override;
  published
    property Titulo: string read FTitulo write SetTitulo;
    property Campo: string read FCampo write FCampo;
    property DataSet: TMyQuery read FDataSet write SetDataSet;
  end;
procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('My Components', [TMyDateTime]);
end;

{ TMyDateTime }

procedure TMyDateTime.AfterOpenQueryPrincipal(prDataSet: TDataSet);
begin
  if prDataSet.FieldByName(FCampo).AsDateTime <> 0 then
    Self.DateTime := prDataSet.FieldByName(FCampo).AsDateTime;
end;

procedure TMyDateTime.BeforePostQueryPrincipal(prDataSet: TDataSet);
begin
  prDataSet.FieldByName(FCampo).AsDateTime := Self.Date;
end;

constructor TMyDateTime.Create(AOwner: TComponent);
begin
  inherited;

  FLblTitulo := TLabel.Create(Self);

  StyleElements := [];
  OnKeyPress := Self.OnKeyPressMyEdit;
end;

destructor TMyDateTime.Destroy;
begin
  if FLblTitulo <> nil then
    FLblTitulo.Free;

  inherited;
end;

procedure TMyDateTime.OnKeyPressMyEdit(Sender: TObject; var prKey: Char);
begin
  if prKey = #13 then
  begin
    prKey := #0;
    keybd_event(VK_TAB, 0, KEYEVENTF_EXTENDEDKEY, 0);
  end;
end;

procedure TMyDateTime.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  inherited;

  if Assigned(FLblTitulo) then
  begin
    FLblTitulo.Left := ALeft;
    FLblTitulo.Top := ATop - 14;
  end;
end;

procedure TMyDateTime.SetDataSet(prValor: TMyQuery);
begin
  if Assigned(prValor) then
  begin
    FDataSet := prValor;

    FDataSet.AddAfterOpen(AfterOpenQueryPrincipal);
    FDataSet.AddBeforePost(BeforePostQueryPrincipal);
  end;
end;

procedure TMyDateTime.SetTitulo(prValor: string);
begin
  FTitulo := prValor;
  Self.FLblTitulo.Caption := prValor;

  if FLblTitulo.Parent <> Self.Parent then
    FLblTitulo.Parent := Self.Parent;
end;

end.
