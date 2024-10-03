unit uFormHO_QUARTO;

interface

uses
  System.Classes, System.SysUtils, Data.DB,
  //
  uFormModelo, uMyQuery;

type
  TFormHO_QUARTO = class(TFormModelo)
  protected
    procedure AdicionarComponente; override;
    procedure BeforePost(prDataSet: TDataSet); override;
   public
     constructor Create(AOwner: TComponent); override;
   end;

implementation

{ TFormHO_QUARTO }

procedure TFormHO_QUARTO.AdicionarComponente;
begin
  AddEdit(1, 'NOME', 'Nome', '');

  //--Tab page COMPLEMENTO
  AddMemo(1, 'OBSERVACAO', 'Observação', 'COMPLEMENTO');
end;

procedure TFormHO_QUARTO.BeforePost(prDataSet: TDataSet);
var
  vQuery: TMyQuery;
begin
  vQuery := TMyQuery.Create(nil);
  try
    vQuery.SQL.Text := ' SELECT A.NOME ' +
                       '   FROM HO_QUARTO A ' +
                       '  WHERE A.NOME = :NOME ' +
                       '    AND A.HANDLE <> ' + IntToStr(Query.FieldByName('HANDLE').AsInteger);
    vQuery.Parameters.ParamByName('NOME').Value := Query.FieldByName('NOME').AsString;
    vQuery.Active := True;

    if not vQuery.Eof then
      raise Exception.Create('Nome inválido!' + sLineBreak +
                             'O nome deste quarto ja existe.' + sLineBreak + sLineBreak +
                             'Quarto: ' + Query.FieldByName('NOME').AsString);
  finally
    vQuery.Free;
  end;
end;

constructor TFormHO_QUARTO.Create(AOwner: TComponent);
begin
  inherited;

  //
end;

initialization
  RegisterClass(TFormHO_QUARTO);

end.
