unit uScript;

interface

uses
  System.Classes, System.SysUtils, Data.DB, Data.Win.ADODB,
  //
  uScriptBase, uMyQuery, uSistema;

type
  TFIScript = class(TScriptBase)
  private
    procedure ExecuteFI_PESSOA();

    //-- TABELA CONTEUDO
    //
  public
    procedure Execute(); override;
  end;

implementation

{ TFIScript }

procedure TFIScript.Execute;
begin
  ExecuteFI_PESSOA();

  //-- TABELA CONTEUDO
  //
end;

procedure TFIScript.ExecuteFI_PESSOA;
const
  vTabela: string = 'FI_PESSOA';
begin
  CriarTabela(vTabela, 'Pessoa', 'Pessoa');
  CriarCampo(vTabela, 'NOME', 'VARCHAR(100)', 'Nome');
  CriarCampo(vTabela, 'OBSERVACAO', 'VARCHAR(200)', 'Observação');
end;

initialization
  RegisterClass(TFIScript);

end.
