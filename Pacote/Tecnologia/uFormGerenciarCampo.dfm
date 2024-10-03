object FormGerenciarCampo: TFormGerenciarCampo
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Gerenciar campo'
  ClientHeight = 442
  ClientWidth = 419
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  TextHeight = 15
  object btnFechar: TSpeedButton
    Left = 0
    Top = 401
    Width = 419
    Height = 41
    Align = alBottom
    Caption = 'Fechar'
    OnClick = btnFecharClick
    ExplicitLeft = 168
    ExplicitTop = 272
    ExplicitWidth = 65
  end
  object pnlSuperior: TPanel
    Left = 0
    Top = 0
    Width = 419
    Height = 41
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 415
    object lblTitulo: TLabel
      Left = 1
      Top = 1
      Width = 417
      Height = 39
      Align = alClient
      Caption = 'MEU TITULO'
      Layout = tlCenter
      ExplicitWidth = 66
      ExplicitHeight = 15
    end
  end
  object dbGrid: TDBGrid
    Left = 0
    Top = 41
    Width = 419
    Height = 360
    Align = alClient
    DataSource = dsPrincipal
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'HANDLE'
        Visible = False
      end
      item
        Expanded = False
        FieldName = 'NOME'
        ReadOnly = True
        Width = 180
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'DESCRICAO'
        Width = 200
        Visible = True
      end>
  end
  object dsPrincipal: TDataSource
    Left = 176
    Top = 160
  end
end
