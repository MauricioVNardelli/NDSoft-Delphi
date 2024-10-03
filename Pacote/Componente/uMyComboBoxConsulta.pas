unit uMyComboBoxConsulta;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.DBCtrls, Vcl.StdCtrls, Data.DB, Vcl.Forms, Winapi.Windows,
  Vcl.ExtCtrls, Vcl.DBGrids,

  uMyQuery;

type
  TFormMyComboBoxConsulta = class(TForm)
  private
    //FPanelTop: TPanel;
    FPanelBottom: TPanel;
    FBtnFechar: TButton;
    FDBGrid: TDBGrid;
    FQuery: TMyQuery;
    FDataSource: TDataSource;

    FHandle: Integer;
    FValor: string;

    procedure FecharOnClick(Sender: TObject);
    procedure DBGridOnDblClick(Sender: TObject);
    procedure OnKeyPressDBGrid(Sender: TObject; var Key: Char);

  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    procedure SetInformacao(const prTabela, prCampo, prValor: string);

    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;

    property Handle: Integer read FHandle;
    property Valor: string read FValor;
  end;


implementation

{ TFormMyComboBoxConsulta }

constructor TFormMyComboBoxConsulta.CreateNew(AOwner: TComponent; Dummy: Integer);
begin
  inherited;

  FQuery := TMyQuery.Create(nil);
  FDataSource := TDataSource.Create(FQuery);
  FDataSource.DataSet := FQuery;
  FDataSource.AutoEdit := False;

  //FPanelTop := TPanel.Create(Self);
  //FPanelTop.Parent := Self;
  //FPanelTop.Align := alTop;
  //FPanelTop.Visible := False;

  FDBGrid := TDBGrid.Create(Self);
  FDBGrid.Parent := Self;
  FDBGrid.Align := alClient;
  FDBGrid.DataSource := FDataSource;
  FDBGrid.OnDblClick := DBGridOnDblClick;
  FDBGrid.OnKeyPress := OnKeyPressDBGrid;

  FPanelBottom := TPanel.Create(Self);
  FPanelBottom.Parent := Self;
  FPanelBottom.Align := alBottom;

  FBtnFechar := TButton.Create(FPanelBottom);
  FBtnFechar.Caption := 'Fechar';
  FBtnFechar.Parent := FPanelBottom;
  FBtnFechar.Align := alClient;
  FBtnFechar.OnClick := FecharOnClick;

  Self.BorderIcons := [TBorderIcon.biSystemMenu];
  Self.Width := 430;
  Self.Height := 300;
  Self.Position	:= poDesktopCenter;
  Self.KeyPreview := True;
end;

procedure TFormMyComboBoxConsulta.DBGridOnDblClick(Sender: TObject);
begin
  FValor := FQuery.FieldByName(FDBGrid.Columns[1].FieldName).AsString;
  FHandle := FQuery.FieldByName(FDBGrid.Columns[0].FieldName).AsInteger;

  Self.Close;
end;

destructor TFormMyComboBoxConsulta.Destroy;
begin
  if Assigned(FQuery) then
    FQuery.Free;

  inherited;
end;

procedure TFormMyComboBoxConsulta.FecharOnClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFormMyComboBoxConsulta.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if Key = VK_ESCAPE then
    Self.Close;
end;

procedure TFormMyComboBoxConsulta.OnKeyPressDBGrid(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    DBGridOnDblClick(Sender);
  end;
end;

procedure TFormMyComboBoxConsulta.SetInformacao(const prTabela, prCampo, prValor: string);
begin
  FQuery.SQL.Text := ' SELECT HANDLE ' + ', ' + prCampo +
                     '   FROM ' + prTabela +
                     '  WHERE STATUS =  3 ';

  if prValor <> '' then
  begin
    FQuery.SQL.Add(' AND ' + prCampo + ' LIKE :VALOR ');
    FQuery.Parameters.ParamByName('VALOR').Value := '%' + prValor + '%';
  end;

  FQuery.Active := True;

  FDBGrid.Columns[0].Visible := False;
  FDBGrid.Columns[1].Width := 380;
  FDBGrid.Columns[1].Title.Caption := 'Valor';
end;

end.
