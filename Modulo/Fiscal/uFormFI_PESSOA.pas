unit uFormFI_PESSOA;

interface

uses
  System.Classes,
  //
  uFormModelo;

type
  TFormFI_PESSOA = class(TFormModelo)
  protected
    procedure AdicionarComponente; override;
   public
    constructor Create(AOwner: TComponent); override;
   end;

implementation

{ TFormFI_PESSOA }

procedure TFormFI_PESSOA.AdicionarComponente;
begin
  AddEdit(1, 'NOME', 'Nome', '');
  AddMemo(1, 'OBSERVACAO', 'Observação', 'COMPLEMENTO')
end;

constructor TFormFI_PESSOA.Create(AOwner: TComponent);
begin
  inherited;

  //
end;

initialization
  RegisterClass(TFormFI_PESSOA);

end.
