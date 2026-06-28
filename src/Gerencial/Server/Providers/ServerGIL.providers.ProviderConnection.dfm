object dmGILConnect: TdmGILConnect
  Height = 414
  Width = 423
  PixelsPerInch = 120
  object conConnectGIL: TFDConnection
    Params.Strings = (
      'Database=intellisoft_GIL'
      'User_Name=root'
      'Password=3t00ls'
      'Server=intellisoftbr.ddns.net'
      'Port=8206'
      'DriverID=MySQL')
    LoginPrompt = False
    Left = 87
    Top = 71
  end
  object drvMySql: TFDPhysMySQLDriverLink
    VendorHome = 'D:\Projetos\Intellisoft_ERP\src\Gerencial\Server'
    VendorLib = 'libmysql.dll'
    Left = 71
    Top = 175
  end
  object qryAux: TFDQuery
    Connection = conConnectGIL
    Left = 79
    Top = 277
  end
  object conConnectERP: TFDConnection
    Params.Strings = (
      'Database=intellisoft_erp'
      'User_Name=root'
      'Password=3t00ls'
      'Port=8206'
      'Server=intellisoftbr.ddns.net'
      'DriverID=MySQL')
    LoginPrompt = False
    Left = 272
    Top = 72
  end
end
