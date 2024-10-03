object FormInicio: TFormInicio
  Left = 0
  Top = 0
  Caption = 'In'#237'cio'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = mmPrincipal
  WindowState = wsMaximized
  TextHeight = 15
  object Button1: TButton
    Left = 408
    Top = 160
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object mmPrincipal: TMainMenu
    Left = 104
    Top = 96
    object miCadastro: TMenuItem
      Caption = 'Cadastro'
      object miQuarto: TMenuItem
        Caption = 'Quarto'
        OnClick = miQuartoClick
      end
      object miPessoa: TMenuItem
        Caption = 'Pessoa'
        OnClick = miPessoaClick
      end
      object miTecnologia: TMenuItem
        Caption = 'Tecnologia'
        object miTecCampo: TMenuItem
          Caption = 'Campo'
          OnClick = miTecCampoClick
        end
      end
    end
    object miMovimentacao: TMenuItem
      Caption = 'Movimenta'#231#227'o'
      object miOrdemServico: TMenuItem
        Caption = 'Ordem de servi'#231'o'
        OnClick = miOrdemServicoClick
      end
    end
  end
end
