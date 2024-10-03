unit uFormModelo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Data.DB, Data.Win.ADODB, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, System.Generics.Collections, Vcl.Buttons,
  //
  uSistema, uConstantes, uMyDBEdit, uMyDBMemo, uMyComboBox, uMyMaskEdit, uMyQuery;

type
  TFormModelo = class(TForm)
  private
    FQuery: TMyQuery;
    FDataSource: TDataSource;
    FPrimeiroComponente: TWinControl;

    FHandle: Integer;
    FTabela: string;
    FCaptionForm: string;

    //-- COMPONENTES
    FPanelTop: TPanel;
    FPanelTabSheet: TPanel;
    FPanelBotoes: TPanel;

    FCodigo: TMyDBEdit;

    FPageControl: TPageControl;
    FTabComplemento: TTabSheet;

    FBotaoLiberar: TSpeedButton;
    FBotaoGravar: TSpeedButton;
    FBotaoVoltar: TSpeedButton;
    FBotaoCancelar: TSpeedButton;
    FBotaoFechar: TSpeedButton;
    FBotaoExcluir: TSpeedButton;

    FListaEdit: TDictionary<string, TMyDBEdit>;
    FListaMemo: TDictionary<string, TMyDBMemo>;
    FListaDateTime: TDictionary<string, TMyMaskEdit>;
    FListaComboBox: TDictionary<string, TMyComboBox>;

    FListaComponenteLinha1: TList<TWinControl>;
    FListaComponenteLinha2: TList<TWinControl>;
    FListaComponenteLinha3: TList<TWinControl>;
    FListaComponenteLinha4: TList<TWinControl>;

    //-- EVENTOS
    procedure btnFecharOnClick(Sender: TObject);
    procedure btnGravarOnClick(Sender: TObject);
    procedure btnLiberarOnClick(Sender: TObject);
    procedure btnVoltarOnClick(Sender: TObject);
    procedure btnCancelarOnClick(Sender: TObject);
    procedure btnExcluirOnClick(Sender: TObject);

    procedure OnMyAfterInsert(prDataSet: TDataSet);

    //-- EVENTOS FORM
    procedure OnShowFormulario(Sender: TObject);

    //--
    procedure ConfigurarComponente(Sender: TObject);
    procedure ConfigurarFormulario();
    procedure AlinharComponente();
    procedure MontarFormulario();

    function GetTopComponent(prLinha: Integer; const prTabPage: string; prComponente: TWinControl): Integer;
  protected
    procedure AdicionarComponente(); virtual; abstract;
    procedure AdicionarEvento(); virtual;

    procedure BeforePost(prDataSet: TDataSet); virtual;
    procedure AfterInsert(prDataSet: TDataSet); virtual;
    procedure AtualizarStatus(prStatus: Integer);

    procedure Liberar(); virtual;
    procedure Voltar(); virtual;
    procedure Cancelar(); virtual;

    //--
    procedure AddEdit(const prLinha: Integer; const prCampo, prTitulo, prTabPage: string; prForcarReadOnly: Boolean; prWidthPercentage: Integer); overload;
    procedure AddEdit(const prLinha: Integer; const prCampo, prTitulo, prTabPage: string; prForcarReadOnly: Boolean); overload;
    procedure AddEdit(const prLinha: Integer; const prCampo, prTitulo, prTabPage: string; prWidthPercentage: Integer); overload;
    procedure AddEdit(const prLinha: Integer; const prCampo, prTitulo, prTabPage: string); overload;

    procedure AddMemo(const prLinha: Integer; const prCampo, prTitulo, prTabPage: string);
    procedure AddDateTime(const prLinha: Integer; const prCampo, prTitulo, prTabPage: string);
    procedure AddComboBox(const prLinha: Integer; const prCampo, prTabela, prCampoListar, prTitulo, prTabPage: string; prWidthPercentage: Integer = 0);

    procedure AddEventoOnAlterar(const prCampo: string; prEvento: TNotifyEvent);
    procedure DoClose(var Action: TCloseAction); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;

    property Query: TMyQuery read FQuery;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy(); override;

     procedure SetHandle(prValor: Integer);
  end;

implementation

{ TFormModelo }

destructor TFormModelo.Destroy;
begin
  if Assigned(FQuery) then
    FreeAndNil(FQuery);

  if FListaEdit <> nil then
    FreeAndNil(FListaEdit);

  if FListaMemo <> nil then
    FreeAndNil(FListaMemo);

  if FListaDateTime <> nil then
    FreeAndNil(FListaDateTime);

  if FListaComboBox <> nil then
    FreeAndNil(FListaComboBox);

  inherited;
end;

procedure TFormModelo.DoClose(var Action: TCloseAction);
begin
  if FQuery.State in [dsInsert, dsEdit] then
  begin
    if MessageDlg('Deseja realmente sair? Lembrando que será desfeito as alterações.', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
      inherited;
  end;
end;

function TFormModelo.GetTopComponent(prLinha: Integer; const prTabPage: string; prComponente: TWinControl): Integer;
begin
  Result := 0;

  if prTabPage = '' then
    Result := 24

  else begin
    case prLinha of
      1:
      begin
        Result := 24;
        FListaComponenteLinha1.Add(prComponente);
      end;

      2:
      begin
        Result := 64;
        FListaComponenteLinha2.Add(prComponente);
      end;

      3:
      begin
        Result := 104;
        FListaComponenteLinha3.Add(prComponente);
      end;

      4:
      begin
        Result := 144;
        FListaComponenteLinha4.Add(prComponente);
      end;
    end;
  end;
end;

procedure TFormModelo.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if Key = VK_ESCAPE then
    Self.Close;
end;

procedure TFormModelo.Liberar;
begin
  AtualizarStatus(TMD_STATUS.Ativo);
end;

procedure TFormModelo.MontarFormulario;
begin
//-- PANEL TOP
  FPanelTop := TPanel.Create(Self);
  FPanelTop.BevelOuter := bvNone;
  FPanelTop.Align := alTop;
  FPanelTop.Height := 57;
  FPanelTop.Parent := Self;

  FCodigo := TMyDBEdit.Create(FPanelTop);
  FCodigo.Parent := FPanelTop;
  FCodigo.Top := 24;
  FCodigo.Width := 75;
  FCodigo.Left := 593;
  FCodigo.Titulo := 'Código';
  FCodigo.DataField := 'HANDLE';
  FCodigo.DataSource := FDataSource;
  FCodigo.ReadOnly := True;

  //-- PANEL SHEET
  FPanelTabSheet := TPanel.Create(Self);
  FPanelTabSheet.Parent := Self;
  FPanelTabSheet.BevelOuter := bvNone;
  FPanelTabSheet.Align := alClient;

  FPageControl := TPageControl.Create(FPanelTabSheet);
  FPageControl.Parent := FPanelTabSheet;
  FPageControl.Align := alClient;
  FPageControl.AlignWithMargins := True;
  FPageControl.Margins.Bottom := 0;
  FPageControl.Margins.Left := 10;
  FPageControl.Margins.Right := 10;
  FPageControl.Margins.Top := 0;

  FTabComplemento := TTabSheet.Create(FPageControl);
  FTabComplemento.Parent := FPageControl;
  FTabComplemento.Caption := 'Complemento';
  FTabComplemento.PageControl := FPageControl;

  //-- PANEL BOTOES
  FPanelBotoes := TPanel.Create(Self);
  FPanelBotoes.Parent := Self;
  FPanelBotoes.BevelOuter := bvNone;
  FPanelBotoes.Align := alBottom;
  FPanelBotoes.Height := 46;
  FPanelBotoes.AlignWithMargins := True;
  FPanelBotoes.Margins.Left := 10;
  FPanelBotoes.Margins.Right := 10;

  FBotaoGravar := TSpeedButton.Create(FPanelBotoes);
  FBotaoGravar.Parent := FPanelBotoes;
  FBotaoGravar.Caption := 'Gravar';
  FBotaoGravar.Align := alLeft;
  FBotaoGravar.AlignWithMargins := True;
  FBotaoGravar.Margins.Bottom := 6;
  FBotaoGravar.Margins.Top := 6;
  FBotaoGravar.Width := 75;
  FBotaoGravar.OnClick := btnGravarOnClick;

  FBotaoLiberar := TSpeedButton.Create(FPanelBotoes);
  FBotaoLiberar.Parent := FPanelBotoes;
  FBotaoLiberar.Caption := 'Liberar';
  FBotaoLiberar.Align := alLeft;
  FBotaoLiberar.AlignWithMargins := True;
  FBotaoLiberar.Margins.Bottom := 6;
  FBotaoLiberar.Margins.Top := 6;
  FBotaoLiberar.Width := 75;
  FBotaoLiberar.OnClick := btnLiberarOnClick;

  FBotaoVoltar := TSpeedButton.Create(FPanelBotoes);
  FBotaoVoltar.Parent := FPanelBotoes;
  FBotaoVoltar.Caption := 'Voltar';
  FBotaoVoltar.Align := alLeft;
  FBotaoVoltar.AlignWithMargins := True;
  FBotaoVoltar.Margins.Bottom := 6;
  FBotaoVoltar.Margins.Top := 6;
  FBotaoVoltar.Width := 75;
  FBotaoVoltar.OnClick := btnVoltarOnClick;

  FBotaoCancelar := TSpeedButton.Create(FPanelBotoes);
  FBotaoCancelar.Parent := FPanelBotoes;
  FBotaoCancelar.Caption := 'Cancelar';
  FBotaoCancelar.Align := alLeft;
  FBotaoCancelar.AlignWithMargins := True;
  FBotaoCancelar.Margins.Bottom := 6;
  FBotaoCancelar.Margins.Top := 6;
  FBotaoCancelar.Width := 75;
  FBotaoCancelar.OnClick := btnCancelarOnClick;

  FBotaoExcluir := TSpeedButton.Create(FPanelBotoes);
  FBotaoExcluir.Parent := FPanelBotoes;
  FBotaoExcluir.Caption := 'Excluir';
  FBotaoExcluir.Align := alLeft;
  FBotaoExcluir.AlignWithMargins := True;
  FBotaoExcluir.Margins.Bottom := 6;
  FBotaoExcluir.Margins.Top := 6;
  FBotaoExcluir.Width := 75;
  FBotaoExcluir.OnClick := btnExcluirOnClick;

  FBotaoFechar := TSpeedButton.Create(FPanelBotoes);
  FBotaoFechar.Parent := FPanelBotoes;
  FBotaoFechar.Caption := 'Fechar';
  FBotaoFechar.Align := alRight;
  FBotaoFechar.AlignWithMargins := True;
  FBotaoFechar.Margins.Bottom := 6;
  FBotaoFechar.Margins.Top := 6;
  FBotaoFechar.Width := 75;
  FBotaoFechar.OnClick := btnFecharOnClick;
end;

procedure TFormModelo.AlinharComponente();
var
  vIndex, vIndex2: Integer;
  vMaxWidth, vSaldoWidth, vLeft, vWidth: Integer;
  vQtdComponente: Integer;
  FListaComponenteLinha: TList<TWinControl>;
begin
  for vIndex2 := 1 to 4 do
  begin
    FListaComponenteLinha := nil;

    case vIndex2 of
      1: FListaComponenteLinha := FListaComponenteLinha1;
      2: FListaComponenteLinha := FListaComponenteLinha2;
      3: FListaComponenteLinha := FListaComponenteLinha3;
      4: FListaComponenteLinha := FListaComponenteLinha4;
    end;

    vQtdComponente := FListaComponenteLinha.Count;
    vMaxWidth := FTabComplemento.Width - 20;

    if vQtdComponente > 1 then
      vMaxWidth := vMaxWidth - (4 * (vQtdComponente - 1));

    if vQtdComponente > 0 then
    begin
      vLeft := 10;
      vSaldoWidth := vMaxWidth;

      for vIndex := 0 to vQtdComponente - 1 do
      begin
        if FListaComponenteLinha[vIndex].Width > 0 then
          vWidth := Round( vMaxWidth * ( FListaComponenteLinha[vIndex].Width / 100) )
        else
          vWidth := Round( vMaxWidth / vQtdComponente );

        if vIndex > 0 then
          vLeft := FListaComponenteLinha[vIndex - 1].Width + FListaComponenteLinha[vIndex - 1].Left + 4;

        if (vIndex = vQtdComponente - 1) and (FListaComponenteLinha[vIndex].Width = 0) then
          vWidth := vSaldoWidth;

        FListaComponenteLinha[vIndex].Left := vLeft;
        FListaComponenteLinha[vIndex].Width := vWidth;

        vSaldoWidth := vSaldoWidth - vWidth;
      end;
    end;
  end;
end;

procedure TFormModelo.AtualizarStatus(prStatus: Integer);
var
  vQuery: TMyQuery;
begin
  vQuery := TMyQuery.Create(nil);
  try
    vQuery.SQL.Text := ' UPDATE ' + FTabela +
                       ' SET STATUS = ' + IntToStr(prStatus) +
                       ' WHERE HANDLE = ' + IntToStr(FHandle);
    vQuery.ExecSQL;

    FQuery.Active := False;
    FQuery.Active := True;
  finally
    vQuery.Free;
  end;
end;

procedure TFormModelo.OnMyAfterInsert(prDataSet: TDataSet);
begin
  if FHandle <= 0 then
  begin
    FQuery.FieldByName('HANDLE').AsInteger := Sistema.NovoHandle(FTabela);
    FQuery.FieldByName('STATUS').AsInteger := TMD_STATUS.Cadastrado;
  end;

  //AlinharComponente();

  Self.AfterInsert(prDataSet);
end;

procedure TFormModelo.OnShowFormulario(Sender: TObject);
begin
  if not FPrimeiroComponente.Enabled then
    FCodigo.SetFocus
  else
    FPrimeiroComponente.SetFocus;
end;

procedure TFormModelo.SetHandle(prValor: Integer);
begin
  FHandle := prValor;

  FQuery.SQL.Text := ' SELECT * FROM ' + FTabela + ' WHERE HANDLE = ' + IntToStr(FHandle);
  FQuery.Active := True;

  if prValor <= 0 then
    FQuery.Insert();

  AlinharComponente();
end;

procedure TFormModelo.Voltar;
begin
  AtualizarStatus(TMD_STATUS.Ag_Modificacao);
end;

procedure TFormModelo.AddComboBox(const prLinha: Integer; const prCampo, prTabela, prCampoListar, prTitulo, prTabPage: string; prWidthPercentage: Integer = 0);
var
  vComponente: TMyComboBox;
begin
  vComponente := TMyComboBox.Create(Self);
  vComponente.DataSet := FQuery;
  vComponente.Campo := prCampoListar;
  vComponente.Tabela := prTabela;
  vComponente.CampoFK := prCampo;

  vComponente.Left := 10;
  vComponente.Width := prWidthPercentage;
  vComponente.Top := GetTopComponent(prLinha, prTabPage, vComponente);

  if (prTabPage = '') then
  begin
    vComponente.Parent := Self;
    vComponente.Titulo := prTitulo;

    vComponente.Width := (FPageControl.Width - FCodigo.Width);

    FPrimeiroComponente := vComponente;
  end else
  if prTabPage = 'COMPLEMENTO' then
  begin
    vComponente.Parent := FTabComplemento;
    vComponente.Titulo := prTitulo;
  end;

  FListaComboBox.Add(prCampo, vComponente);
end;

procedure TFormModelo.AddDateTime(const prLinha: Integer; const prCampo, prTitulo, prTabPage: string);
var
  vComponente: TMyMaskEdit;
begin
  vComponente := TMyMaskEdit.Create(Self);
  vComponente.Parent := FTabComplemento;
  vComponente.DataSource := FDataSource;
  vComponente.Campo := prCampo;
  vComponente.Titulo := prTitulo;
  vComponente.TipoMascara := myDateTime;

  vComponente.Left := 10;
  vComponente.Top := GetTopComponent(prLinha, prTabPage, vComponente);
  vComponente.Width := 20; //%

  FListaDateTime.Add(prCampo, vComponente);
end;

procedure TFormModelo.AddEdit(const prLinha: Integer; const prCampo, prTitulo, prTabPage: string; prForcarReadOnly: Boolean; prWidthPercentage: Integer);
var
  vComponente: TMyDBEdit;
begin
  vComponente := TMyDBEdit.Create(Self);
  vComponente.DataSource := FDataSource;
  vComponente.DataField := prCampo;
  vComponente.Left := 10;
  vComponente.Top := GetTopComponent(prLinha, prTabPage, vComponente);
  vComponente.Titulo := prTitulo;
  vComponente.Width := prWidthPercentage;
  vComponente.ForcarReadOnly := prForcarReadOnly;

  FListaEdit.Add(prCampo, vComponente);

  if (prTabPage = '') then
  begin
    vComponente.Parent := FPanelTop;
    vComponente.Width := (FPageControl.Width - FCodigo.Width);

    FPrimeiroComponente := vComponente;
  end else
  if (prTabPage <> '') then
    vComponente.Parent := FTabComplemento;
end;

procedure TFormModelo.AddEdit(const prLinha: Integer; const prCampo, prTitulo, prTabPage: string; prForcarReadOnly: Boolean);
begin
  Self.AddEdit(prLinha, prCampo, prTitulo, prTabPage, prForcarReadOnly, 0);
end;

procedure TFormModelo.AddEdit(const prLinha: Integer; const prCampo, prTitulo, prTabPage: string; prWidthPercentage: Integer);
begin
  Self.AddEdit(prLinha, prCampo, prTitulo, prTabPage, False, prWidthPercentage);
end;

procedure TFormModelo.AddEventoOnAlterar(const prCampo: string; prEvento: TNotifyEvent);
var
  vMyDBEdit: TMyDBEdit;
  vMyMaskEdit: TMyMaskEdit;
  vMyCombobox: TMyComboBox;
begin
  FListaEdit.TryGetValue(prCampo, vMyDBEdit);
  FListaDateTime.TryGetValue(prCampo, vMyMaskEdit);
  FListaComboBox.TryGetValue(prCampo, vMyCombobox);

  if vMyDBEdit <> nil then
    vMyDBEdit.AddOnChange(prEvento);

  if vMyMaskEdit <> nil then
    vMyMaskEdit.AddOnChange(prEvento);

  {if vMyCombobox <> nil then
    vMyCombobox.AddOnChange(prEvento);}
end;

procedure TFormModelo.AddMemo(const prLinha: Integer; const prCampo, prTitulo, prTabPage: string);
var
  vComponente: TMyDBMemo;
  vParent: TWinControl;
  vHeight: Integer;
begin
  vHeight := 0;
  vParent := Self;

  if prTabPage = 'COMPLEMENTO' then
    vParent := FTabComplemento;

  case prLinha of
    1: vHeight := 143;
    2: vHeight := 103;
    3: vHeight := 63;
  end;

  vComponente := TMyDBMemo.Create(Self);
  vComponente.Parent := vParent;
  vComponente.DataSource := FDataSource;
  vComponente.DataField := prCampo;
  vComponente.Titulo := prTitulo;

  vComponente.Left := 10;
  vComponente.Top := GetTopComponent(prLinha, prTabPage, vComponente);
  vComponente.Height := vHeight;
  vComponente.Width := 0;

  FListaMemo.Add(prCampo, vComponente);
end;

procedure TFormModelo.AdicionarEvento;
begin
  //
end;

procedure TFormModelo.AfterInsert(prDataSet: TDataSet);
begin
  //
end;

procedure TFormModelo.BeforePost(prDataSet: TDataSet);
begin
  //
end;

procedure TFormModelo.btnCancelarOnClick(Sender: TObject);
var
  vQuery: TMyQuery;
begin
  vQuery := TMyQuery.Create(nil);
  try
    if MessageDlg('Deseja realmente cancelar o registro?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
    begin
      vQuery.SQL.Text := ' UPDATE ' + FTabela +
                         '    SET STATUS = ' + IntToStr(TMD_STATUS.Cancelado) +
                         '  WHERE HANDLE = ' + IntToStr(FHandle);
      vQuery.ExecSQL;

      FQuery.Active := False;
      FQuery.Active := True;

      Cancelar();
    end;
  finally
    vQuery.Free;
  end;

end;

procedure TFormModelo.btnExcluirOnClick(Sender: TObject);
begin
  if MessageDlg('Deseja realmente excluir o registro?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
    FQuery.Delete();
end;

procedure TFormModelo.btnFecharOnClick(Sender: TObject);
begin
  Self.Close;
end;

procedure TFormModelo.btnGravarOnClick(Sender: TObject);
begin
  FQuery.Post;

  //--
  //GravarOnClick();
end;

procedure TFormModelo.btnLiberarOnClick(Sender: TObject);
begin
  if MessageDlg('Deseja realmente liberar o registro?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
    Liberar();

  FQuery.Active := False;
  FQuery.Active := True;
end;

procedure TFormModelo.btnVoltarOnClick(Sender: TObject);
begin
  if MessageDlg('Deseja realmente voltar a situação do registro?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    Voltar();
  end;
end;

procedure TFormModelo.Cancelar;
begin
  //
end;

procedure TFormModelo.ConfigurarComponente(Sender: TObject);
var
  vPodeAlterar: Boolean;

  vMyEdit: TPair<string, TMyDBEdit>;
  vMyMemo: TPair<string, TMyDBMemo>;
  vMyDateTime: TPair<string, TMyMaskEdit>;
  vMyComboBox: TPair<string, TMyComboBox>;
begin
  if FQuery.Active then
  begin
    ConfigurarFormulario();

    if FQuery.FindField('STATUS') <> nil then
      vPodeAlterar := FQuery.FieldByName('STATUS').AsInteger in [0, TMD_STATUS.Cadastrado, TMD_STATUS.Ag_Modificacao]
    else
      vPodeAlterar := (FQuery.State in [dsInsert, dsEdit]);

    for vMyEdit in FListaEdit do
      vMyEdit.Value.ReadOnly := not vPodeAlterar;

    for vMyMemo in FListaMemo do
      vMyMemo.Value.ReadOnly := not vPodeAlterar;

    for vMyDateTime in FListaDateTime do
      vMyDateTime.Value.ReadOnly := not vPodeAlterar;

    for vMyComboBox in FListaComboBox do
      vMyComboBox.Value.ReadOnly := not vPodeAlterar;

    Application.ProcessMessages;
  end;
end;

procedure TFormModelo.ConfigurarFormulario;
var
  vQuery: TMyQuery;
begin
  Self.Caption := FCaptionForm;

  vQuery := TMyQuery.Create(nil);
  try
    FBotaoGravar.Visible := Query.State in [dsInsert, dsEdit];

    if FQuery.FindField('STATUS') <> nil then
    begin
      vQuery.SQL.Text := ' SELECT DESCRICAO ' +
                         '   FROM MD_STATUS ' +
                         '  WHERE HANDLE = ' + IntToStr(FQuery.FieldByName('STATUS').AsInteger);
      vQuery.Active := True;

      Self.Caption := FCaptionForm + ' - ' + vQuery.FieldByName('DESCRICAO').AsString;

      FBotaoVoltar.Visible := not (FQuery.FieldByName('STATUS').AsInteger in [TMD_STATUS.Cadastrado, TMD_STATUS.Ag_Modificacao]);
      FBotaoLiberar.Visible := FQuery.FieldByName('STATUS').AsInteger in [TMD_STATUS.Cadastrado, TMD_STATUS.Ag_Modificacao];
      FBotaoCancelar.Visible := FQuery.FieldByName('STATUS').AsInteger = TMD_STATUS.Ag_Modificacao;
      FBotaoExcluir.Visible := FQuery.FieldByName('STATUS').AsInteger = TMD_STATUS.Cadastrado;
    end;
  finally
    vQuery.Free;
  end;
end;

constructor TFormModelo.CreateNew(AOwner: TComponent; Dummy: Integer);
var
  vQuery: TMyQuery;
begin
  inherited;

  FTabela := StringReplace(Self.ClassName, 'TForm', '', [rfReplaceAll, rfIgnoreCase]);

  vQuery := TMyQuery.Create(nil);
  try
    vQuery.SQL.Text := ' SELECT DESCRICAO FROM MD_TABELA WHERE NOME = :TABELA ';
    vQuery.Parameters.ParamByName('TABELA').Value := FTabela;
    vQuery.Active := True;

    FCaptionForm := vQuery.FieldByName('DESCRICAO').AsString;
  finally
    vQuery.Free();
  end;

  FQuery := TMyQuery.Create(nil);
  FQuery.AddBeforePost(BeforePost);
  FQuery.AddAfterInsert(OnMyAfterInsert);

  FDataSource := TDataSource.Create(FQuery);
  FDataSource.DataSet := FQuery;
  FDataSource.OnStateChange := ConfigurarComponente;

  Self.BorderStyle := bsSingle;
  Self.Position := poDesktopCenter;
  Self.Width := 690;
  Self.Height := 350;
  Self.BorderIcons := [TBorderIcon.biSystemMenu];
  Self.OnShow := OnShowFormulario;
  Self.KeyPreview := True;

  FListaEdit := TDictionary<string, TMyDBEdit>.Create;
  FListaMemo := TDictionary<string, TMyDBMemo>.Create;
  FListaDateTime := TDictionary<string, TMyMaskEdit>.Create;
  FListaComboBox := TDictionary<string, TMyComboBox>.Create;

  FListaComponenteLinha1 := TList<TWinControl>.Create;
  FListaComponenteLinha2 := TList<TWinControl>.Create;
  FListaComponenteLinha3 := TList<TWinControl>.Create;
  FListaComponenteLinha4 := TList<TWinControl>.Create;

  MontarFormulario();

  AdicionarComponente();
  AdicionarEvento();
end;

procedure TFormModelo.AddEdit(const prLinha: Integer; const prCampo, prTitulo, prTabPage: string);
begin
  Self.AddEdit(prLinha, prCampo, prTitulo, prTabPage, False, 0);
end;

initialization
  RegisterClass(TFormModelo);

finalization
  UnRegisterClass(TFormModelo);

end.
