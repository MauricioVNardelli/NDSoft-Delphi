unit uFormHO_ORDEM;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFormModelo, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.DBCtrls, Vcl.ComCtrls, uMyComboBox, Vcl.Mask, uMyDBEdit,
  Vcl.Grids, Vcl.ValEdit, uMyMaskEdit;

type
  TFormHO_ORDEM = class(TformModelo)
    mbQuarto: TMyComboBox;
    mbCanal: TMyComboBox;
    edtValor: TMyDBEdit;
    edtAcrescimo: TMyDBEdit;
    edtDesconto: TMyDBEdit;
    edtValorTotal: TMyDBEdit;
    edtDataCheckout: TMyDBEdit;
    edtDataCheckin: TMyDBEdit;
    edtPessoa: TMyComboBox;

    procedure edtValorExit(Sender: TObject);
    procedure edtAcrescimoExit(Sender: TObject);
    procedure edtDescontoExit(Sender: TObject);
  private
    procedure AtualizarValorTotal();
  public
    //
  end;

var
  FormHO_ORDEM: TFormHO_ORDEM;

implementation

{$R *.dfm}

procedure TFormHO_ORDEM.AtualizarValorTotal;
begin
  Query.FieldByName('VALORTOTAL').AsCurrency := Query.FieldByName('VALOR').AsCurrency -
                                                Query.FieldByName('VALORDESCONTO').AsCurrency +
                                                Query.FieldByName('VALORACRESCIMO').AsCurrency;
end;

procedure TFormHO_ORDEM.edtAcrescimoExit(Sender: TObject);
begin
  inherited;

  AtualizarValorTotal();
end;

procedure TFormHO_ORDEM.edtDescontoExit(Sender: TObject);
begin
  inherited;

  AtualizarValorTotal();
end;

procedure TFormHO_ORDEM.edtValorExit(Sender: TObject);
begin
  inherited;

  AtualizarValorTotal();
end;

initialization
  RegisterClass(TFormHO_ORDEM);

finalization
  UnRegisterClass(TFormHO_ORDEM);

end.
