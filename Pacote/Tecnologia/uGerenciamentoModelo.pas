unit uGerenciamentoModelo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls,
  Data.Win.ADODB, System.UITypes, TypInfo, System.Generics.Collections, Vcl.Buttons,
  //
  uSistema, uConstantes, uMyQuery, uFormModelo, uMyEditFiltro, Vcl.Menus, uFormGerenciarCampo;

type
  TGerenciamentoModelo = class(TForm)
  private
    FTabela: string;

    FDBPrincipal: TDBGrid;
    FLblTitulo: TLabel;

    FPnlBotoes: TPanel;
    FPnlRodape: TPanel;
    FPnlTitulo: TPanel;
    FPnlPesquisa: TPanel;

    FBtnFechar: TBitBtn;
    FBtnExcluir: TBitBtn;
    FBtnInserir: TBitBtn;
    FBtnPendente: TSpeedButton;

    FPopMenu: TPopupMenu;
    FMISalvar: TMenuItem;
    FMIGerenciarCampo: TMenuItem;

    FQueryGerenciamento: TMyQuery;
    FDataSource: TDataSource;
    FListaEditPesquisa: TDictionary<string, TMyEditFiltro>;

    //--EVENTOS BOTAO
    procedure btnFecharClick(Sender: TObject);
    procedure btnInserirClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnPendenteClick(Sender: TObject);

    procedure miSalvarClick(Sender: TObject);
    procedure miGerenciarCampoClick(Sender: TObject);

    procedure setTabela(prTabela: string);

    procedure ConfigurarGrid();
    procedure ConfigurarFiltro();
    procedure FormatarValorGrid();
    procedure MontarFormulario();
    procedure ConfigurarFormulario();
    procedure AbrirFormulario(prHandle: Integer);
    procedure RegistrarTelaGerenciamento();

    //Eventos
    procedure OnDblClickDbGrid(Sender: TObject);
    procedure EditFiltroOnExit(Sender: TObject);
    procedure OnAfterOpenQuery(prDataSet: TDataSet);
    procedure DBGridOnColumnDataCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);

    procedure AdicionarFiltroQuery();
  protected
    function GetSQL(): string; virtual; abstract;
    function GetFiltroPendente(): string; virtual;
  public
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;

    property Tabela: string write setTabela;
  end;

var
  formGerenciamento: TGerenciamentoModelo;

implementation

procedure TGerenciamentoModelo.AbrirFormulario(prHandle: Integer);
var
  vClasseTabela: TPersistentClass;

  vFormModelo: TFormModelo;
begin
  if prHandle <> 0 then
  begin
    vClasseTabela := GetClass('TForm' + FTabela);

    if vClasseTabela = nil then
      raise Exception.Create('Formulário da tabela não encontrada' + sLineBreak +
                             'Tabela: ' + FTabela);

    vFormModelo := TFormModelo(vClasseTabela.Create).CreateNew(nil);
    try
      vFormModelo.SetHandle(prHandle);
      vFormModelo.ShowModal();
    finally
      FreeAndNil(vFormModelo);

      FQueryGerenciamento.Active := False;
      FQueryGerenciamento.Active := True;
    end;
  end;
end;

procedure TGerenciamentoModelo.btnExcluirClick(Sender: TObject);
begin
  if MessageDlg('Deseja realmente excluir o registro selecionado?', TMsgDlgType.mtInformation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    FQueryGerenciamento.Delete();

    ConfigurarFormulario();
  end;
end;

procedure TGerenciamentoModelo.btnFecharClick(Sender: TObject);
begin
  Self.Close();

  if FQueryGerenciamento <> nil then
    FreeAndNil(FQueryGerenciamento);
end;

procedure TGerenciamentoModelo.btnInserirClick(Sender: TObject);
begin
  AbrirFormulario(-1);
end;

procedure TGerenciamentoModelo.btnPendenteClick(Sender: TObject);
begin
  FQueryGerenciamento.Active := False;
  FQueryGerenciamento.SQL.Text := ' SELECT * FROM ( ' + GetSQL + ' ) ORI WHERE 1 = 1 ';
  FQueryGerenciamento.SQL.Add(GetFiltroPendente());

  FQueryGerenciamento.SQL.Add(' ORDER BY 1 DESC ');
  FQueryGerenciamento.Active := True;
end;

procedure TGerenciamentoModelo.ConfigurarFiltro;
var
  vIndex: Integer;
  vNewEdit: TMyEditFiltro;
  vEdit: TPair<string, TMyEditFiltro>;
  vLeft: Integer;
begin
  for vEdit in FListaEditPesquisa do
    vEdit.Value.Free;

  FListaEditPesquisa.Clear;

  vLeft := 28;
  for vIndex := 1 to FDBPrincipal.Columns.Count - 1 do
  begin
    vNewEdit := TMyEditFiltro.Create(nil);
    vNewEdit.Parent := FPnlPesquisa;
    vNewEdit.Text := '';
    vNewEdit.TextHint := FDBPrincipal.Columns[vIndex].Title.Caption;
    vNewEdit.Left := vLeft;
    vNewEdit.Top := 6;
    vNewEdit.Width := FDBPrincipal.Columns[vIndex].Width - 2;
    vNewEdit.OnExit := EditFiltroOnExit;
    vNewEdit.FieldType := FDBPrincipal.Columns[vIndex].Field.DataType;

    vLeft := vLeft + vNewEdit.Width + 3;

    FListaEditPesquisa.Add(FDBPrincipal.Columns[vIndex].FieldName, vNewEdit);
  end;
end;

procedure TGerenciamentoModelo.ConfigurarFormulario;
begin
  FBtnExcluir.Enabled := FQueryGerenciamento.RecordCount > 0;
end;

procedure TGerenciamentoModelo.ConfigurarGrid;
var
  vColumn: TColumn;
  vQuery: TMyQuery;
begin
  vQuery := TMyQuery. Create(nil);
  try
    vQuery.SQL.Text := ' SELECT A.INDICECOLUNA, ' +
                       '        A.LARGURA, ' +
                       '        A.NOME, ' +
                       '        A.DESCRICAO ' +
                       '   FROM MD_TELAGERENCIAMENTOCAMPO A ' +
                       '  INNER JOIN MD_TELAGERENCIAMENTO B ON B.HANDLE = A.TELAGERENCIAMENTO ' +
                       '  WHERE B.NOME = :NOME ' +
                       '  ORDER BY INDICECOLUNA ';
    vQuery.Parameters.ParamByName('NOME').Value := Self.Name;
    vQuery.Active := True;

    if not vQuery.Eof then
    begin
      vColumn := FDBPrincipal.Columns.Add;
      vColumn.Index := 0;
      vColumn.Width := 10;
      vColumn.Title.Caption := '';
    end;

    while not vQuery.Eof do
    begin
      vColumn := FDBPrincipal.Columns.Add;

      vColumn.FieldName := vQuery.FieldByName('NOME').AsString;
      vColumn.Index := vQuery.FieldByName('INDICECOLUNA').AsInteger;
      vColumn.Width := vQuery.FieldByName('LARGURA').AsInteger;
      vColumn.Title.Caption := vQuery.FieldByName('DESCRICAO').AsString;

      if vColumn.FieldName = 'STATUS' then
        vColumn.Visible := False;

      vQuery.Next;
    end;
  finally
    vQuery.Free;
  end;
end;

constructor TGerenciamentoModelo.CreateNew(AOwner: TComponent; Dummy: Integer = 0);
begin
  inherited;

  MontarFormulario();

  FQueryGerenciamento := TMyQuery.Create(nil);
  FDataSource := TDataSource.Create(FQueryGerenciamento);
  FDataSource.DataSet := FQueryGerenciamento;
  FDataSource.AutoEdit := False;

  FDBPrincipal.DataSource := FDataSource;
  FDBPrincipal.OnDblClick := OnDblClickDbGrid;
  FDBPrincipal.ReadOnly := True;

  FListaEditPesquisa := TDictionary<string, TMyEditFiltro>.Create;

  FQueryGerenciamento.AfterOpen := OnAfterOpenQuery;
end;

procedure TGerenciamentoModelo.DBGridOnColumnDataCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  if DataCol = 0 then
  begin
    case FQueryGerenciamento.FieldByName('STATUS').AsInteger of
      TMD_STATUS.Cadastrado: FDBPrincipal.Canvas.Brush.Color := clMedGray;
      TMD_STATUS.Ativo: FDBPrincipal.Canvas.Brush.Color := clGreen;
      TMD_STATUS.Encerrado: FDBPrincipal.Canvas.Brush.Color := clGreen;
      TMD_STATUS.Ag_Modificacao: FDBPrincipal.Canvas.Brush.Color := clWebOrange;
      TMD_STATUS.Em_Execucao: FDBPrincipal.Canvas.Brush.Color := clWebChartreuse;
      TMD_STATUS.Cancelado: FDBPrincipal.Canvas.Brush.Color := clWebMaroon;
    end;
  end;

  FDBPrincipal.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

destructor TGerenciamentoModelo.Destroy;
begin
  if FQueryGerenciamento <> nil then
    FreeAndNil(FQueryGerenciamento);

  if FListaEditPesquisa <> nil then
    FListaEditPesquisa.Free;

  inherited;
end;

procedure TGerenciamentoModelo.EditFiltroOnExit(Sender: TObject);
begin
  AdicionarFiltroQuery();
end;

procedure TGerenciamentoModelo.FormatarValorGrid;
var
  vIndex: Integer;
  vField: TField;
begin
  for vIndex := 0 to FDBPrincipal.FieldCount - 1 do
  begin
    vField := FDBPrincipal.Fields[vIndex];

    if vField <> nil then
    begin
      case vField.DataType of
        ftFloat, ftCurrency, ftBCD: TNumericField(vField).DisplayFormat := '###,###,##0.00';

        ftDateTime:
        begin
          TDateTimeField(vField).DisplayFormat := 'dd/mm/yyyy hh:mm';
          vField.Alignment := taCenter;
        end;

        ftDate:
        begin
          TDateField(vField).DisplayFormat := 'dd/mm/yyyy';
          vField.Alignment := taCenter;
        end;
      end;
    end;
  end;
end;

procedure TGerenciamentoModelo.AdicionarFiltroQuery;
var
  vIndexParam: Integer;
  vParam: string;
  vNewParameter: TParameter;
  vPair: TPair<string, TMyEditFiltro>;
begin
  vIndexParam := 0;

  FQueryGerenciamento.Active := False;
  FQueryGerenciamento.Parameters.Clear;
  FQueryGerenciamento.SQL.Text := ' SELECT * FROM ( ' + GetSQL + ' ) ORI WHERE 1 = 1 ';
  FQueryGerenciamento.SQL.Add(GetFiltroPendente);

  for vPair in FListaEditPesquisa do
  begin
    if vPair.Value.Text <> '' then
    begin
      vParam := 'VALOR' + IntToStr(vIndexParam);

      case vPair.Value.FieldType of
        ftString:
        begin
          FQueryGerenciamento.SQL.Add(' AND ' + vPair.Key + ' LIKE :' + vParam);
          FQueryGerenciamento.Parameters.ParamByName(vParam).Value := '%' +  vPair.Value.Text + '%';
        end;

        ftInteger:
        begin
          FQueryGerenciamento.SQL.Add(' AND ' + vPair.Key + ' = :' + vParam);
          FQueryGerenciamento.Parameters.ParamByName(vParam).Value := StrToInt(vPair.Value.Text);
        end;

        ftCurrency, ftBCD, ftFloat:
        begin
          FQueryGerenciamento.SQL.Add(' AND ' + vPair.Key + ' = :' + vParam);
          FQueryGerenciamento.Parameters.ParamByName(vParam).Value := StrToFloat(vPair.Value.Text);
        end;
      end;

      vIndexParam := vIndexParam + 1;
    end;
  end;

  FQueryGerenciamento.SQL.Add(' ORDER BY 1 DESC ');
  FQueryGerenciamento.Active := True;
end;

function TGerenciamentoModelo.GetFiltroPendente: string;
begin
  Result := '';

  if FBtnPendente.Down then
    Result := ' AND STATUS NOT IN ( ' + IntToStr(TMD_STATUS.Ativo) + ', ' +
                                        IntToStr(TMD_STATUS.Cancelado) + ', ' +
                                        IntToStr(TMD_STATUS.Encerrado) + ' )'
end;

procedure TGerenciamentoModelo.miGerenciarCampoClick(Sender: TObject);
var
  vForm: TFormGerenciarCampo;
begin
  vForm := TFormGerenciarCampo.Create(nil);
  try
    vForm.setTabela(FTabela);
    vForm.ShowModal();
  finally
    vForm.Free;
  end;
end;

procedure TGerenciamentoModelo.miSalvarClick(Sender: TObject);
var
  vIndex, vIndiceColuna, vHandleGerenciamento: Integer;

  vQuery: TMyQuery;
begin
  vQuery := TMyQuery.Create(nil);
  try
    vHandleGerenciamento := Sistema.GetHandle('MD_TELAGERENCIAMENTO', 'NOME', Self.Name);

    vQuery.SQL.Text := ' DELETE MD_TELAGERENCIAMENTOCAMPO ' +
                       '  WHERE TELAGERENCIAMENTO = ' + IntToStr(vHandleGerenciamento);
    vQuery.ExecSQL;

    vQuery.SQL.Text := ' SELECT * FROM MD_TELAGERENCIAMENTOCAMPO WHERE 1 = 0 ';
    vQuery.Active := True;

    vIndiceColuna := 0;
    for vIndex := 0 to FDBPrincipal.Columns.Count - 1 do
    begin
      if FDBPrincipal.Columns[vIndex].FieldName <> '' then
      begin
        vIndiceColuna := vIndiceColuna + 1;

        vQuery.Insert;
        vQuery.FieldByName('HANDLE').AsInteger := Sistema.NovoHandle('MD_TELAGERENCIAMENTOCAMPO');
        vQuery.FieldByName('TELAGERENCIAMENTO').AsInteger := vHandleGerenciamento;
        vQuery.FieldByName('INDICECOLUNA').AsInteger := vIndiceColuna;
        vQuery.FieldByName('NOME').AsString := FDBPrincipal.Columns[vIndex].FieldName;
        vQuery.FieldByName('DESCRICAO').AsString := FDBPrincipal.Columns[vIndex].Title.Caption;
        vQuery.FieldByName('LARGURA').AsInteger := FDBPrincipal.Columns[vIndex].Width;
        vQuery.Post();
      end;
    end;
  finally
    vQuery.Free;
  end;
end;

procedure TGerenciamentoModelo.MontarFormulario;
var
  vCaminho: string;
begin
  vCaminho := ExtractFileDir(Application.ExeName) + '\assets';

  Self.BorderStyle := bsNone;

  FPnlBotoes := TPanel.Create(Self);
  FPnlBotoes.Align := alTop;
  FPnlBotoes.Height := 75;
  FPnlBotoes.Parent := Self;

  FBtnInserir := TBitBtn.Create(FPnlBotoes);
  FBtnInserir.Parent := FPnlBotoes;
  FBtnInserir.Align := alLeft;
  FBtnInserir.Caption := 'Inserir';
  FBtnInserir.AlignWithMargins := True;
  FBtnInserir.Glyph.LoadFromFile(vCaminho + '\button_add.bmp');
  //--Posicao
  FBtnInserir.Layout := blGlyphTop;
  FBtnInserir.Width := 73;
  FBtnInserir.Margins.Bottom := 3;
  FBtnInserir.Margins.Top := 3;
  FBtnInserir.Margins.Left := 12;
  FBtnInserir.Margins.Right := 3;
  FBtnInserir.OnClick := Self.btnInserirClick;

  FBtnPendente := TSpeedButton.Create(FPnlBotoes);
  FBtnPendente.Parent := FPnlBotoes;
  FBtnPendente.Align := alLeft;
  FBtnPendente.Caption := 'Pendente';
  FBtnPendente.AlignWithMargins := True;
  FBtnPendente.Transparent := False;
  FBtnPendente.AllowAllUp := True;
  FBtnPendente.GroupIndex := 1;
  FBtnPendente.Glyph.LoadFromFile(vCaminho + '\button_pendente.bmp');
  //--Posicao
  FBtnPendente.Layout := blGlyphTop;
  FBtnPendente.Width := 73;
  FBtnPendente.Margins.Bottom := 3;
  FBtnPendente.Margins.Top := 3;
  FBtnPendente.Margins.Left := 3;
  FBtnPendente.Margins.Right := 3;
  FBtnPendente.OnClick := Self.btnPendenteClick;

  FBtnExcluir := TBitBtn.Create(FPnlBotoes);
  FBtnExcluir.Parent := FPnlBotoes;
  FBtnExcluir.Align := alLeft;
  FBtnExcluir.Caption := 'Excluir';
  FBtnExcluir.AlignWithMargins := True;
  FBtnExcluir.Glyph.LoadFromFile(vCaminho + '\button_delete.bmp');
  //--Posicao
  FBtnExcluir.Layout := blGlyphTop;
  FBtnExcluir.Width := 73;  
  FBtnExcluir.Margins.Bottom := 3;
  FBtnExcluir.Margins.Top := 3;
  FBtnExcluir.Margins.Left := 3;
  FBtnExcluir.Margins.Right := 3;

  FBtnExcluir.OnClick := Self.btnExcluirClick;

  FBtnFechar := TBitBtn.Create(FPnlBotoes);
  FBtnFechar.Parent := FPnlBotoes;
  FBtnFechar.Align := alRight;
  FBtnFechar.Caption := 'Fechar';
  FBtnFechar.AlignWithMargins := True;
  FBtnFechar.Glyph.LoadFromFile(vCaminho + '\button_close.bmp');
  //--Posicao
  FBtnFechar.Layout := blGlyphTop;
  FBtnFechar.Width := 73;    
  FBtnFechar.Margins.Bottom := 3;
  FBtnFechar.Margins.Top := 3;
  FBtnFechar.Margins.Left := 3;
  FBtnFechar.Margins.Right := 12;
  FBtnFechar.OnClick := Self.btnFecharClick;

  FPnlTitulo := TPanel.Create(Self);
  FPnlTitulo.Align := alTop;
  FPnlTitulo.Height := 40;
  FPnlTitulo.Parent := Self;

  FPnlPesquisa := TPanel.Create(Self);
  FPnlPesquisa.Align := alTop;
  FPnlPesquisa.Height := 36;
  FPnlPesquisa.Parent := Self;

  FLblTitulo := TLabel.Create(FPnlTitulo);
  FLblTitulo.Parent := FPnlTitulo;
  FLblTitulo.Align := alClient;
  FLblTitulo.Layout := tlCenter;
  FLblTitulo.Alignment := taCenter;
  FLblTitulo.BiDiMode := bdLeftToRight;
  FLblTitulo.Font.Style := [TFontStyle.fsBold];
  FLblTitulo.Font.Size := 15;

  FPopMenu := TPopupMenu.Create(Self);

  FMISalvar := TMenuItem.Create(FPopMenu);
  FMISalvar.Caption := 'Salvar';
  FMISalvar.OnClick := Self.miSalvarClick;
  FPopMenu.Items.Add(FMISalvar);

  FMIGerenciarCampo := TMenuItem.Create(FPopMenu);
  FMIGerenciarCampo.Caption := 'Gerenciar campo';
  FMIGerenciarCampo.OnClick := Self.miGerenciarCampoClick;
  FPopMenu.Items.Add(FMIGerenciarCampo);

  FDBPrincipal := TDBGrid.Create(Self);
  FDBPrincipal.Parent := Self;
  FDBPrincipal.Align := alClient;
  FDBPrincipal.PopupMenu := FPopMenu;
  FDBPrincipal.OnDrawColumnCell := DBGridOnColumnDataCell;

  FPnlRodape := TPanel.Create(Self);
  FPnlRodape.Align := alBottom;
  FPnlRodape.Height := 30;
  FPnlRodape.Parent := Self;
end;

procedure TGerenciamentoModelo.OnAfterOpenQuery(prDataSet: TDataSet);
begin
  FormatarValorGrid();
end;

procedure TGerenciamentoModelo.OnDblClickDbGrid(Sender: TObject);
begin
  AbrirFormulario(FQueryGerenciamento.FieldByName('HANDLE').AsInteger);
end;

procedure TGerenciamentoModelo.RegistrarTelaGerenciamento;
var
  vHandleGerenciamento: Integer;

  vQuery: TMyQuery;
begin
  vQuery := TMyQuery.Create(nil);
  try
    vHandleGerenciamento := Sistema.GetHandle('MD_TELAGERENCIAMENTO', 'NOME', Self.Name);

    vQuery.SQL.Text := ' SELECT * FROM MD_TELAGERENCIAMENTO WHERE 1 = 0 ';
    vQuery.Active := True;

    if vHandleGerenciamento = 0 then
    begin
      vQuery.Insert;
      vQuery.FieldByName('HANDLE').AsInteger := Sistema.NovoHandle('MD_TELAGERENCIAMENTO');
      vQuery.FieldByName('NOME').AsString := Self.Name;
      vQuery.FieldByName('TITULO').AsString := FLblTitulo.Caption;
      vQuery.FieldByName('TABELA').AsInteger := Sistema.GetHandle('MD_TABELA', 'NOME', FTabela);
      vQuery.Post();
    end;
  finally
    vQuery.Free;
  end;
end;

procedure TGerenciamentoModelo.setTabela(prTabela: string);
var
  vQuery: TMyQuery;
begin
  FTabela := prTabela;

  vQuery := TMyQuery.Create(nil);
  try
    vQuery.SQL.Text := 'SELECT DESCRICAOGERENCIAMENTO FROM MD_TABELA WHERE NOME = :NOME';
    vQuery.Parameters.ParamByName('NOME').Value := prTabela;
    vQuery.Active := True;

    FLblTitulo.Caption := AnsiUpperCase(vQuery.FieldByName('DESCRICAOGERENCIAMENTO').AsString);
    FBtnPendente.Down := True;

    FQueryGerenciamento.Active := False;
    FQueryGerenciamento.SQL.Text := ' SELECT * FROM ( ' + GetSQL + ' ) ORI WHERE 1 = 1 ';
    FQueryGerenciamento.SQL.Add(GetFiltroPendente());
    FQueryGerenciamento.SQL.Add(' ORDER BY 1 DESC ');
    FQueryGerenciamento.Active := True;

    ConfigurarFormulario();
    RegistrarTelaGerenciamento();
    ConfigurarGrid();
    ConfigurarFiltro();
  finally
    vQuery.Free();
  end;
end;

end.

