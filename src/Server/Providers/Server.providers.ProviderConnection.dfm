object dmSrvConnect: TdmSrvConnect
  OnCreate = DataModuleCreate
  Height = 315
  Width = 470
  PixelsPerInch = 120
  object conConnect: TFDConnection
    Params.Strings = (
      'Database=intellisoft_erp'
      'User_Name=root'
      'Password=3t00ls'
      'Server=192.168.18.10'
      'Port=8206'
      'DriverID=MySQL')
    LoginPrompt = False
    Left = 48
    Top = 32
  end
  object drvMySql: TFDPhysMySQLDriverLink
    Left = 48
    Top = 112
  end
  object qryAux: TFDQuery
    Connection = conConnect
    Left = 48
    Top = 192
  end
end
