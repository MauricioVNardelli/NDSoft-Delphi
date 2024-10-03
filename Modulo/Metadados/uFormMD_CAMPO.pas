unit uFormMD_CAMPO;

interface

uses
  System.Classes, System.SysUtils, Data.DB,
  //
  uFormModelo, uMyQuery;

type
  TFormMD_CAMPO = class(TFormModelo)
  protected
    procedure AdicionarComponente; override;
    procedure BeforePost(prDataSet: TDataSet); override;
   public
     constructor Create(AOwner: TComponent); override;
   end;

implementation

{ TFormMD_CAMPO }

procedure TFormMD_CAMPO.AdicionarComponente;
begin
  AddEdit(1, 'NOME', 'Nome', '');

  //--Tab page COMPLEMENTO
  AddEdit(1, 'DESCRICAO', 'Descrição', 'COMPLEMENTO');
  AddComboBox(2, 'TABELA', 'MD_TABELA', 'NOME', 'Tabela', 'COMPLEMENTO');
  AddMemo(3, 'OBSERVACAO', 'Observação', 'COMPLEMENTO');
end;

procedure TFormMD_CAMPO.BeforePost(prDataSet: TDataSet);
var
  vQuery: TMyQuery;
begin
  vQuery := TMyQuery.Create(nil);
  try
    vQuery.SQL.Text := ' SELECT B.NOME TABELA ' +
                       '   FROM MD_CAMPO A ' +
                       '  INNER JOIN MD_TABELA B ON B.HANDLE = A.TABELA ' +
                       '  WHERE A.NOME = :NOME ' +
                       '    AND A.TABELA = ' + IntToStr(Query.FieldByName('TABELA').AsInteger) +
                       '    AND A.HANDLE <> ' + IntToStr(Query.FieldByName('HANDLE').AsInteger);
    vQuery.Parameters.ParamByName('NOME').Value := Query.FieldByName('NOME').AsString;
    vQuery.Active := True;

    if not vQuery.Eof then
      raise Exception.Create('Campo inválido!' + sLineBreak +
                             'O nome do campo informado ja existe para essa tabela.' + sLineBreak + sLineBreak +
                             'Campo: ' + Query.FieldByName('NOME').AsString + sLineBreak +
                             'Tabela: ' + vQuery.FieldByName('TABELA').AsString);
  finally
    vQuery.Free;
  end;
end;

constructor TFormMD_CAMPO.Create(AOwner: TComponent);
begin
  inherited;

  //
end;

initialization
  RegisterClass(TFormMD_CAMPO);

end.
