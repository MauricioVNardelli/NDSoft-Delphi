unit uFormMD_CAMPO;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uFormModelo, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, uMyDBEdit, Vcl.ComCtrls, uMyComboBox;

type
  TFormMD_CAMPO = class(TformModelo)
    edtNome: TMyDBEdit;
    edtDescricao: TMyDBEdit;
    cbTabela: TMyComboBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMD_CAMPO: TFormMD_CAMPO;

implementation

{$R *.dfm}

initialization
  RegisterClass(TFormMD_CAMPO);

finalization
  UnRegisterClass(TFormMD_CAMPO);

end.
