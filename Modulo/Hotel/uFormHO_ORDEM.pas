unit uFormHO_ORDEM;

interface

uses
  System.Classes, System.SysUtils, Data.DB, DateUtils,
  //
  uFormModelo, uMyQuery, uConstantes;

type
  TFormHO_ORDEM = class(TFormModelo)
  private
    procedure ValorUnitarioOnAlterar(Sender: TObject);
    procedure DataOnAlterar(Sender: TObject);
  protected
    procedure AdicionarComponente; override;
    procedure AdicionarEvento; override;

    procedure Liberar; override;
  public
     //
  end;

implementation

{ TFormHO_ORDEM }

procedure TFormHO_ORDEM.AdicionarComponente;
begin
  AddComboBox(1, 'PESSOA', 'FI_PESSOA', 'NOME', 'Cliente', '');

  //-- COMPLEMENTO - LINHA 1
  AddDateTime(1, 'DATACHECKIN', 'Check in', 'COMPLEMENTO');
  AddDateTime(1, 'DATACHECKOUT', 'Check out', 'COMPLEMENTO');
  AddEdit(1, 'QUANTIDADEDIA', 'Dias', 'COMPLEMENTO', True, 7);
  AddComboBox(1, 'QUARTO', 'HO_QUARTO', 'NOME', 'Quarto', 'COMPLEMENTO');

  //-- COMPLEMENTO - LINHA 2
  AddComboBox(2, 'CANAL', 'HO_CANAL', 'NOME', 'Canal', 'COMPLEMENTO', 48);
  AddEdit(2, 'VALORUNITARIO', 'Vlr unitário', 'COMPLEMENTO', 13);
  AddEdit(2, 'VALORACRESCIMO', 'Acréscimo', 'COMPLEMENTO', 13);
  AddEdit(2, 'VALORDESCONTO', 'Desconto', 'COMPLEMENTO', 13);
  AddEdit(2, 'VALORTOTAL', 'Vlr total', 'COMPLEMENTO', 13);

  //-- COMPLEMENTO - LINHA 3 e 4
  AddMemo(3, 'OBSERVACAO', 'Observação', 'COMPLEMENTO');
end;

procedure TFormHO_ORDEM.AdicionarEvento;
begin
  AddEventoOnAlterar('VALORUNITARIO', Self.ValorUnitarioOnAlterar);
  AddEventoOnAlterar('DATACHECKIN', Self.DataOnAlterar);
  AddEventoOnAlterar('DATACHECKOUT', Self.DataOnAlterar);
end;

procedure TFormHO_ORDEM.DataOnAlterar(Sender: TObject);
begin
  if (Query.FieldByName('DATACHECKIN').AsDateTime <> 0) and (Query.FieldByName('DATACHECKOUT').AsDateTime <> 0) then
    Query.FieldByName('QUANTIDADEDIA').AsInteger := DaysBetween(Query.FieldByName('DATACHECKIN').AsDateTime, Query.FieldByName('DATACHECKOUT').AsDateTime);
end;

procedure TFormHO_ORDEM.Liberar;
begin
  AtualizarStatus(TMD_STATUS.Encerrado);
end;

procedure TFormHO_ORDEM.ValorUnitarioOnAlterar(Sender: TObject);
begin
  Query.FieldByName('VALORTOTAL').AsCurrency := (Query.FieldByName('QUANTIDADEDIA').AsInteger *
                                                Query.FieldByName('VALORUNITARIO').AsCurrency) +
                                                Query.FieldByName('VALORACRESCIMO').AsCurrency -
                                                Query.FieldByName('VALORDESCONTO').AsCurrency;
end;

initialization
  RegisterClass(TFormHO_ORDEM);

end.
