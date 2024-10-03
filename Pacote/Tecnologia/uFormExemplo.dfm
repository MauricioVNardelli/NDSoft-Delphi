object FormModelo: TFormModelo
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  ClientHeight = 310
  ClientWidth = 670
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object pnlSuperior: TPanel
    Left = 0
    Top = 0
    Width = 670
    Height = 57
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 666
    object edtCodigo: TMyDBEdit
      Left = 593
      Top = 25
      Width = 75
      Height = 23
      TabOrder = 0
      StyleElements = []
      WidthPercentual = 0
      Titulo = 'C'#243'digo'
    end
    object edtNome: TMyDBEdit
      Left = 10
      Top = 25
      Width = 579
      Height = 23
      TabOrder = 1
      StyleElements = []
      WidthPercentual = 0
      Titulo = 'Nome'
    end
  end
  object pnlPrincipal: TPanel
    Left = 0
    Top = 57
    Width = 670
    Height = 207
    Margins.Left = 10
    Margins.Top = 0
    Margins.Right = 10
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 666
    ExplicitHeight = 206
    object tcPrincipal: TPageControl
      AlignWithMargins = True
      Left = 10
      Top = 0
      Width = 650
      Height = 207
      Margins.Left = 10
      Margins.Top = 0
      Margins.Right = 10
      Margins.Bottom = 0
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      ExplicitWidth = 646
      ExplicitHeight = 206
      object TabSheet1: TTabSheet
        Caption = 'Complemento'
        object MyDBEdit1: TMyDBEdit
          Left = 10
          Top = 24
          Width = 298
          Height = 23
          TabOrder = 0
          StyleElements = []
          WidthPercentual = 0
          Titulo = 'Nome'
        end
        object MyDBEdit2: TMyDBEdit
          Left = 10
          Top = 64
          Width = 431
          Height = 23
          TabOrder = 1
          StyleElements = []
          WidthPercentual = 0
          Titulo = 'Nome'
        end
        object MyDBEdit3: TMyDBEdit
          Left = 10
          Top = 104
          Width = 431
          Height = 23
          TabOrder = 2
          StyleElements = []
          WidthPercentual = 0
          Titulo = 'Nome'
        end
        object MyDBEdit4: TMyDBEdit
          Left = 10
          Top = 144
          Width = 298
          Height = 23
          TabOrder = 3
          StyleElements = []
          WidthPercentual = 0
          Titulo = 'Nome'
        end
        object Memo1: TMemo
          Left = 447
          Top = 104
          Width = 186
          Height = 63
          Lines.Strings = (
            'Memo1')
          TabOrder = 4
        end
        object MyDBEdit5: TMyDBEdit
          Left = 312
          Top = 144
          Width = 129
          Height = 23
          TabOrder = 5
          StyleElements = []
          WidthPercentual = 0
          Titulo = 'Nome'
        end
        object DateTimePicker1: TDateTimePicker
          Left = 321
          Top = 24
          Width = 120
          Height = 23
          CalColors.BackColor = clWhite
          Date = 45017.000000000000000000
          Format = 'dd/mm/yyyy hh:mm'
          Time = 0.294267766206758100
          Checked = False
          DoubleBuffered = False
          Kind = dtkDateTime
          ParentDoubleBuffered = False
          TabOrder = 6
        end
      end
    end
  end
  object pnlBotoes: TPanel
    AlignWithMargins = True
    Left = 10
    Top = 264
    Width = 650
    Height = 46
    Margins.Left = 10
    Margins.Top = 0
    Margins.Right = 10
    Margins.Bottom = 0
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitTop = 263
    ExplicitWidth = 646
    object btnFechar: TButton
      Left = 575
      Top = 0
      Width = 75
      Height = 46
      Align = alRight
      Caption = 'Fechar'
      TabOrder = 0
      ExplicitLeft = 571
    end
    object btnGravarEditar: TButton
      AlignWithMargins = True
      Left = 3
      Top = 8
      Width = 75
      Height = 30
      Margins.Top = 8
      Margins.Bottom = 8
      Align = alLeft
      Caption = 'Gravar'
      TabOrder = 1
    end
  end
end
