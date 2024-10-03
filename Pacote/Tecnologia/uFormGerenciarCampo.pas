unit uFormGerenciarCampo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.Buttons, Vcl.StdCtrls,
  //
  uSistema, uMyQuery;

type
  TFormGerenciarCampo = class(TForm)
    pnlSuperior: TPanel;
    dbGrid: TDBGrid;
    btnFechar: TSpeedButton;
    lblTitulo: TLabel;
    dsPrincipal: TDataSource;
    procedure btnFecharClick(Sender: TObject);
  private
    FMyQuery: TMyQuery;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure setTabela(const prTabela: string);
  end;

var
  FormGerenciarCampo: TFormGerenciarCampo;

implementation

{$R *.dfm}

{ TFormGerenciarCampo }

constructor TFormGerenciarCampo.Create(AOwner: TComponent);
begin
  inherited;

  FMyQuery := TMyQuery.Create(nil);

  Self.dsPrincipal.DataSet := FMyQuery;
end;

destructor TFormGerenciarCampo.Destroy;
begin
  if FMyQuery <> nil then
    FMyQuery.Free;

  inherited;
end;

procedure TFormGerenciarCampo.btnFecharClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFormGerenciarCampo.setTabela(const prTabela: string);
begin
  FMyQuery.SQL.Text := ' SELECT HANDLE, NOME, DESCRICAO ' +
                       '   FROM MD_TELAGERENCIAMENTOCAMPO ' +
                       '  WHERE TELAGERENCIAMENTO = :TELAGERENCIAMENTO ';
  FMyQuery.Parameters.ParamByName('TELAGERENCIAMENTO').Value := Sistema.GetHandle('MD_TELAGERENCIAMENTO', 'NOME', prTabela);
  FMyQuery.Active := True;
end;

end.
