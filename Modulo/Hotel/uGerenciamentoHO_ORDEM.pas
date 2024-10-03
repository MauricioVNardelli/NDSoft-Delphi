unit uGerenciamentoHO_ORDEM;

interface

uses
  System.Classes,
  //
  uGerenciamentoModelo;

type
  TGerenciamentoHO_ORDEM = class(TGerenciamentoModelo)
  private
    //
  protected
    function GetSQL: string; override;
  public
    //
  end;

implementation

{ TGerenciamentoHO_ORDEM }

function TGerenciamentoHO_ORDEM.GetSQL: string;
begin
  Result := ' SELECT A.HANDLE, ' +
            '        A.STATUS, ' +
            '        B.NOME PESSOA, ' +
            '        C.NOME CANAL, ' +
            '        A.DATACHECKIN, ' +
            '        A.DATACHECKOUT, ' +
            '        A.OBSERVACAO, ' +
            '        A.QUANTIDADEDIA, ' +
            '        D.NOME QUARTO, ' +
            '        A.VALORUNITARIO, ' +
            '        A.VALORACRESCIMO, ' +
            '        A.VALORDESCONTO, ' +
            '        A.VALORTOTAL ' +

            '   FROM HO_ORDEM A ' +
            '   LEFT JOIN FI_PESSOA B ON B.HANDLE = A.PESSOA ' +
            '   LEFT JOIN HO_CANAL C ON C.HANDLE = A.CANAL ' +
            '   LEFT JOIN HO_QUARTO D ON D.HANDLE = A.QUARTO ';
end;

initialization
  RegisterClass(TGerenciamentoHO_ORDEM);

end.
