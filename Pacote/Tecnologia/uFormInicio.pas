unit uFormInicio;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB, Data.Win.ADODB,
  Vcl.StdCtrls, uGerenciamentoExemplo,
  //
  uSistema, uGerenciamentoModelo, uMyMainMenu;

type
  TFormInicio = class(TForm)
    mmPrincipal: TMainMenu;
    miCadastro: TMenuItem;
    miQuarto: TMenuItem;
    miMovimentacao: TMenuItem;
    miOrdemServico: TMenuItem;
    miPessoa: TMenuItem;
    miTecnologia: TMenuItem;
    miTecCampo: TMenuItem;
    Button1: TButton;

    procedure miQuartoClick(Sender: TObject);
    procedure miOrdemServicoClick(Sender: TObject);
    procedure miPessoaClick(Sender: TObject);
    procedure miTecCampoClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FFormGerenciamento: TGerenciamentoModelo;

    procedure AbrirTelaGerenciamento(prTabela: string);
  public
    destructor Destroy; override;
  end;

var
  FormInicio: TFormInicio;

implementation

{$R *.dfm}

procedure TFormInicio.AbrirTelaGerenciamento(prTabela: string);
var
  vClasseTabela: TPersistentClass;
begin
  if FFormGerenciamento <> nil then
    FFormGerenciamento.Free;

  vClasseTabela := GetClass('TGerenciamento' + prTabela);

  if vClasseTabela = nil then
    raise Exception.Create('Tela de gerenciamento da tabela não encontrada' + sLineBreak +
                           'Tabela: ' + prTabela);

  FFormGerenciamento := TGerenciamentoModelo(vClasseTabela.Create).CreateNew(nil);
  FFormGerenciamento.Parent := Self;
  FFormGerenciamento.Name := prTabela;
  FFormGerenciamento.Tabela := prTabela;

  FFormGerenciamento.Show();
  FFormGerenciamento.Align := alClient;
end;

procedure TFormInicio.Button1Click(Sender: TObject);
var
  vExemplo: TGerenciamentoExemplo;
begin
  vExemplo := TGerenciamentoExemplo.Create(nil);
  try
    vExemplo.ShowModal;
  finally
    vExemplo.Free;
  end;
end;

destructor TFormInicio.Destroy;
begin
  if FFormGerenciamento <> nil then
    FFormGerenciamento.Free();

  inherited;
end;

procedure TFormInicio.miOrdemServicoClick(Sender: TObject);
begin
  AbrirTelaGerenciamento('HO_ORDEM');
end;

procedure TFormInicio.miPessoaClick(Sender: TObject);
begin
  AbrirTelaGerenciamento('FI_PESSOA');
end;

procedure TFormInicio.miQuartoClick(Sender: TObject);
begin
  AbrirTelaGerenciamento('HO_QUARTO');
end;

procedure TFormInicio.miTecCampoClick(Sender: TObject);
begin
  AbrirTelaGerenciamento('MD_CAMPO');
end;

end.

