program NDSoft;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Winapi.Windows,
  //
  uSistema,
  uFormInicio;

{$R *.res}

var
  vFormInicio: TFormInicio;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  Sistema := TSistema.GetInstance();
  try
    Sistema.CarregarDll();

    {$IFDEF DEBUG}
    Sistema.AnalisarTabela();
    {$ENDIF}

    Application.CreateForm(TFormInicio, vFormInicio);
    try
      if Assigned(vFormInicio) then
      begin
        Application.Run;
      end;
    finally
      vFormInicio.Free();
    end;
  finally
    Sistema.Free();
  end;

end.
