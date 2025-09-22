object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'D-Invader 3D'
  ClientHeight = 600
  ClientWidth = 800
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnKeyUp = FormKeyUp
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlUI: TPanel
    Left = 0
    Top = 0
    Width = 800
    Height = 60
    Align = alTop
    Color = clNavy
    ParentBackground = False
    TabOrder = 0
    object lblScore: TLabel
      Left = 16
      Top = 8
      Width = 49
      Height = 16
      Caption = 'Score: 0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblLives: TLabel
      Left = 16
      Top = 32
      Width = 48
      Height = 16
      Caption = 'Lives: 3'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblInstructions: TLabel
      Left = 200
      Top = 20
      Width = 350
      Height = 13
      Caption = 'Use A/D para mover, SPACE para atirar, ESC para sair'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clYellow
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object btnStart: TButton
      Left = 600
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Iniciar'
      TabOrder = 0
      OnClick = btnStartClick
    end
  end
  object pnlGame: TPanel
    Left = 0
    Top = 60
    Width = 800
    Height = 540
    Align = alClient
    Color = clBlack
    ParentBackground = False
    TabOrder = 1
    OnPaint = pnlGamePaint
  end
  object pnlGameOver: TPanel
    Left = 200
    Top = 200
    Width = 400
    Height = 200
    Color = clMaroon
    ParentBackground = False
    TabOrder = 2
    Visible = False
    object lblGameOver: TLabel
      Left = 120
      Top = 50
      Width = 160
      Height = 29
      Caption = 'GAME OVER'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -24
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnRestart: TButton
      Left = 160
      Top = 120
      Width = 80
      Height = 30
      Caption = 'Reiniciar'
      TabOrder = 0
      Visible = False
      OnClick = btnRestartClick
    end
  end
  object tmrGame: TTimer
    Enabled = False
    Interval = 16
    OnTimer = tmrGameTimer
    Left = 720
    Top = 16
  end
end