unit uMyMainMenu;

interface

uses
  System.SysUtils, System.Classes, Vcl.Menus;

type
  TMyMenuItem = class(TMenuItem)
  private
    FTabela: string;
  protected
     { Protected declarations }
  public
    { Public declarations }
  published
    property Tabela: string read FTabela write FTabela;
  end;

  TMyMainMenu = class(TMainMenu)
  private
    FTabela: string;
  protected
     { Protected declarations }
  public
    function CreateMenuItem: TMenuItem; override;
  published
    property Tabela: string read FTabela write FTabela;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('My Components', [TMyMainMenu]);
end;

{ TMyMainMenu }

function TMyMainMenu.CreateMenuItem: TMenuItem;
begin
  Result := TMyMenuItem.Create(Self);
end;

end.
