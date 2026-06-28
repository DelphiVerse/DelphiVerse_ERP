inherited dmSrvConnect1: TdmSrvConnect1
  PixelsPerInch = 120
  object qryCadastro: TFDQuery
    Connection = conConnect
    SQL.Strings = (
      'select * from intellisoft_GIL.clientes ')
    Left = 176
    Top = 32
    object qryCadastroid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = False
    end
    object qryCadastrorazao_social: TStringField
      FieldName = 'razao_social'
      Origin = 'razao_social'
      Required = True
      Size = 100
    end
    object qryCadastronome_fantasia: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'nome_fantasia'
      Origin = 'nome_fantasia'
      Size = 100
    end
    object qryCadastrocpf_cnpj: TStringField
      FieldName = 'cpf_cnpj'
      Origin = 'cpf_cnpj'
      Required = True
      Size = 15
    end
    object qryCadastrostatus: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'status'
      Origin = '`status`'
      Size = 1
    end
  end
  object qryClientes: TFDQuery
    Connection = conConnect
    SQL.Strings = (
      'select * from intellisoft_GIL.clientes ')
    Left = 176
    Top = 128
    object qryClientesid: TFDAutoIncField
      FieldName = 'id'
      Origin = 'id'
      ProviderFlags = [pfInWhere, pfInKey]
      ReadOnly = False
    end
    object qryClientesrazao_social: TStringField
      FieldName = 'razao_social'
      Origin = 'razao_social'
      Required = True
      Size = 100
    end
    object qryClientesnome_fantasia: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'nome_fantasia'
      Origin = 'nome_fantasia'
      Size = 100
    end
    object qryClientescpf_cnpj: TStringField
      FieldName = 'cpf_cnpj'
      Origin = 'cpf_cnpj'
      Required = True
      Size = 15
    end
    object qryClientesstatus: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'status'
      Origin = '`status`'
      Size = 1
    end
  end
end
