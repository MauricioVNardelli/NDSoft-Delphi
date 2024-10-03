unit uFormExemplo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Data.Win.ADODB, Data.DB,
  Vcl.ComCtrls, Vcl.Mask, Vcl.DBCtrls,
  //
  uSistema, uMyDBEdit, uMyComboBox, uMyDBMemo, uMyQuery;

type
  TFormModelo = class(TForm)
    btnFechar: TButton;
    btnGravarEditar: TButton;
    pnlPrincipal: TPanel;
    tcPrincipal: TPageControl;
    pnlSuperior: TPanel;
    edtCodigo: TMyDBEdit;
    pnlBotoes: TPanel;
    edtNome: TMyDBEdit;
    MyDBEdit1: TMyDBEdit;
    MyDBEdit2: TMyDBEdit;
    MyDBEdit3: TMyDBEdit;
    MyDBEdit4: TMyDBEdit;
    Memo1: TMemo;
    MyDBEdit5: TMyDBEdit;
    DateTimePicker1: TDateTimePicker;
    //
  private
    //
  protected
    //
  public
    //
  end;

  implementation

{$R *.dfm}

end.

