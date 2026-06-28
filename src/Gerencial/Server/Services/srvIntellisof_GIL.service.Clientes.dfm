inherited dmGILConnectClientes: TdmGILConnectClientes
  OnCreate = DataModuleCreate
  PixelsPerInch = 120
  inherited drvMySql: TFDPhysMySQLDriverLink
    Left = 87
    Top = 167
  end
  inherited qryAux: TFDQuery
    Top = 253
  end
  object qryCadastro: TFDQuery
    CachedUpdates = True
    Connection = conConnectGIL
    UpdateOptions.AssignedValues = [uvRefreshMode, uvCountUpdatedRecords]
    UpdateOptions.RefreshMode = rmManual
    UpdateOptions.CountUpdatedRecords = False
    UpdateOptions.UpdateTableName = 'clientes'
    SQL.Strings = (
      'select * from clientes')
    Left = 80
    Top = 336
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
    object qryCadastrorg_ie: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'rg_ie'
      Origin = 'rg_ie'
    end
    object qryCadastrostatus: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'status'
      Origin = '`status`'
      Size = 1
    end
    object qryCadastrodata_cadastro: TDateTimeField
      AutoGenerateValue = arDefault
      FieldName = 'data_cadastro'
      Origin = 'data_cadastro'
    end
    object qryCadastroobservacoes: TMemoField
      AutoGenerateValue = arDefault
      FieldName = 'observacoes'
      Origin = 'observacoes'
      BlobType = ftMemo
    end
    object qryCadastrotelefone: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'telefone'
      Origin = 'telefone'
      Size = 11
    end
    object qryCadastroemail: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'email'
      Origin = 'email'
      Size = 100
    end
    object qryCadastrocep: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'cep'
      Origin = 'cep'
      Size = 8
    end
    object qryCadastroendereco: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'endereco'
      Origin = 'endereco'
      Size = 100
    end
    object qryCadastronumero: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'numero'
      Origin = 'numero'
      Size = 10
    end
    object qryCadastrocomplemento: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'complemento'
      Origin = 'complemento'
      Size = 50
    end
    object qryCadastrobairro: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'bairro'
      Origin = 'bairro'
      Size = 50
    end
    object qryCadastrocidade: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'cidade'
      Origin = 'cidade'
      Size = 50
    end
    object qryCadastrouf: TStringField
      AutoGenerateValue = arDefault
      FieldName = 'uf'
      Origin = 'uf'
      Size = 2
    end
    object qryCadastrotipo_pessoa: TIntegerField
      FieldName = 'tipo_pessoa'
      Origin = 'tipo_pessoa'
      Required = True
    end
  end
  object qryERP: TFDQuery
    CachedUpdates = True
    Connection = conConnectERP
    Left = 272
    Top = 176
  end
end
