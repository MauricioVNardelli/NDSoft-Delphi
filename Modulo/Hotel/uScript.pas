unit uScript;

interface

uses
  System.Classes, System.SysUtils, Data.DB, Data.Win.ADODB, Vcl.Forms,
  //
  uScriptBase, uMyQuery, uSistema;

type
  THOScript = class(TScriptBase)
  private
    procedure ExecuteHO_QUARTO();
    procedure ExecuteHO_ORDEM();

    //-- TABELA CONTEUDO
    procedure ExecuteHO_CANAL();
  public
    procedure Execute(); override;
  end;

implementation

{ THOScript }

procedure THOScript.Execute;
begin
  //-- TABELA CONTEUDO
  ExecuteHO_CANAL();

  ExecuteHO_QUARTO();
  ExecuteHO_ORDEM();
end;

procedure THOScript.ExecuteHO_CANAL;
const
  vTabela: string = 'HO_CANAL';
begin
  CriarTabela(vTabela, 'Canal', 'Canal');
  CriarCampo(vTabela, 'NOME', 'VARCHAR(30)', 'Nome');

  InserirRegistro(vTabela, 'NOME', 'Booking');
  InserirRegistro(vTabela, 'NOME', 'Presencial');
  InserirRegistro(vTabela, 'NOME', 'Telefone');
  InserirRegistro(vTabela, 'NOME', 'Whatsapp');
end;

procedure THOScript.ExecuteHO_ORDEM;
const
  vTabela: string = 'HO_ORDEM';
begin
  CriarTabela(vTabela, 'Ordem de serviço', 'Ordem de serviço');

  CriarCampo(vTabela, 'PESSOA', 'INTEGER', 'Pessoa');
  CriarCampo(vTabela, 'CANAL', 'INTEGER', 'Canal');
  CriarCampo(vTabela, 'DATACHECKIN', 'DATETIME', 'Check in');
  CriarCampo(vTabela, 'DATACHECKOUT', 'DATETIME', 'Check out');
  CriarCampo(vTabela, 'OBSERVACAO', 'VARCHAR(200)', 'Observação');
  CriarCampo(vTabela, 'QUANTIDADEDIA', 'INTEGER', 'Dias');
  CriarCampo(vTabela, 'QUARTO', 'INTEGER', 'Quarto');
  CriarCampo(vTabela, 'VALORUNITARIO', 'NUMERIC(12,2)', 'Valor unitário');
  CriarCampo(vTabela, 'VALORACRESCIMO', 'NUMERIC(12,2)', 'Acréscimo');
  CriarCampo(vTabela, 'VALORDESCONTO', 'NUMERIC(12,2)', 'Desconto');
  CriarCampo(vTabela, 'VALORTOTAL', 'NUMERIC(12,2)', 'Valor total');

  CriarForeignKey(vTabela, 'FI_PESSOA', 'PESSOA');
  CriarForeignKey(vTabela, 'HO_CANAL', 'CANAL');
  CriarForeignKey(vTabela, 'HO_QUARTO', 'QUARTO');
end;

procedure THOScript.ExecuteHO_QUARTO;
const
  vTabela: string = 'HO_QUARTO';
begin
  CriarTabela(vTabela, 'Quarto', 'Quarto');
  CriarCampo(vTabela, 'NOME', 'VARCHAR(30)', 'Nome');
  CriarCampo(vTabela, 'OBSERVACAO', 'VARCHAR(200)', 'Observação');
end;

initialization
  RegisterClass(THOScript);

end.
