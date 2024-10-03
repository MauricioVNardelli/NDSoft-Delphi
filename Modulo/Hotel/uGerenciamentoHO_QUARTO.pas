unit uGerenciamentoHO_QUARTO;

interface

uses
  System.Classes,
  //
  uGerenciamentoModelo;

type
  TGerenciamentoHO_QUARTO = class(TGerenciamentoModelo)
  private
    //
  protected
    function GetSQL: string; override;
  public
    //
  end;

implementation

{ TGerenciamentoHO_QUARTO }

function TGerenciamentoHO_QUARTO.GetSQL: string;
begin
  Result := ' SELECT A.HANDLE, ' +
            '        A.NOME, ' +
            '        A.OBSERVACAO, ' +
            '        A.STATUS ' +

            '   FROM HO_QUARTO A ';
end;

initialization
  RegisterClass(TGerenciamentoHO_QUARTO);

end.
