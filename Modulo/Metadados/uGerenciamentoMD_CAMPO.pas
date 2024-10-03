unit uGerenciamentoMD_CAMPO;

interface

uses
  System.Classes,
  //
  uGerenciamentoModelo;

type
  TGerenciamentoMD_CAMPO = class(TGerenciamentoModelo)
  private
    //
  protected
    function GetSQL: string; override;
  public
    //
  end;

implementation

{ TGerenciamentoMD_CAMPO }

function TGerenciamentoMD_CAMPO.GetSQL: string;
begin
  Result := ' SELECT A.HANDLE, ' +
            '        A.NOME, ' +
            '        A.DESCRICAO, ' +
            '        B.NOME TABELA, ' +
            '        A.OBSERVACAO ' +

            '   FROM MD_CAMPO A ' +
            '   LEFT JOIN MD_TABELA B ON B.HANDLE = A.TABELA ' +
            '  WHERE 1 = 1 ';
end;

initialization
  RegisterClass(TGerenciamentoMD_CAMPO);

end.
