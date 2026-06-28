unit Gerencial.model.LicencaStatus;

interface

type
  TLicencaStatus = (lsAtiva, lsBloqueada, lsErro);

  TLicencaEstado = record
    Status: TLicencaStatus;
    Mensagem: string;
    DiasRestantes: Integer;
    SomenteLeitura: Boolean;
    PixCopiaCola: string;
    PixQrCodeBase64: string;
  end;

implementation

end.
