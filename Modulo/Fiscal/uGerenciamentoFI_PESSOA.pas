unit uGerenciamentoFI_PESSOA;

interface

uses
  System.Classes,
  //
  uGerenciamentoModelo;

type
  TGerenciamentoFI_PESSOA = class(TGerenciamentoModelo)
  private
    //
  protected
    function GetSQL: string; override;
  public
    //
  end;

implementation

{ TGerenciamentoFI_PESSOA }

function TGerenciamentoFI_PESSOA.GetSQL: string;
begin
  Result := ' SELECT A.HANDLE, ' +
            '        A.NOME, ' +
            '        A.OBSERVACAO, ' +
            '        A.STATUS ' +

            '   FROM FI_PESSOA A ' +
            '  WHERE 1 = 1 ';
end;

initialization
  RegisterClass(TGerenciamentoFI_PESSOA);

end.
