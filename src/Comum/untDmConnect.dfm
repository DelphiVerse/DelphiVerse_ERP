object dmConnect: TdmConnect
  Height = 386
  Width = 340
  PixelsPerInch = 120
  object conConnect: TFDConnection
    Left = 56
    Top = 24
  end
  object drvMySql1: TFDPhysMySQLDriverLink
    Left = 56
    Top = 120
  end
  object qryAux: TFDQuery
    Connection = conConnect
    Left = 56
    Top = 216
  end
end
