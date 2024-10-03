unit uGerenciamentoExemplo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls,
  Data.Win.ADODB, System.UITypes, TypInfo, Vcl.Mask,
  //
  uSistema, uMyQuery, uFormModelo, Vcl.Menus, System.ImageList, Vcl.ImgList, Vcl.Buttons, Vcl.ComCtrls,
  Vcl.WinXCalendars, Vcl.WinXPickers, Data.DBXMySQL, Data.SqlExpr;

type
  TGerenciamentoExemplo = class(TForm)
    dbPrincipal: TDBGrid;
    pnlBotoes: TPanel;
    pnlRodape: TPanel;
    pnlTitulo: TPanel;
    lblTitulo: TLabel;
    SpeedButton2: TSpeedButton;
    SpeedButton1: TSpeedButton;
    BitBtn1: TBitBtn;
    Panel1: TPanel;
    LabeledEdit1: TLabeledEdit;
    Panel2: TPanel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    MaskEdit1: TMaskEdit;
  private
    //
  protected
    //
  public
    //
  end;

  {
  Application Name=NDSoft;Provider=SQLNCLI11;Server=localhost;Database=NDSoft;Uid=sa;Password=#mauricio123
  }

var
  formGerenciamento: TGerenciamentoExemplo;

implementation

{$R *.dfm}

{ TGerenciamentoExemplo }

end.

