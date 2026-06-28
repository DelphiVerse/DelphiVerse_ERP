unit IntellisoftERP.controller.Licenca;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Net.HttpClient,
  System.Threading,

  IntellisoftERP.model.Licenca;

type
  TOnValidarLicencaProc = reference to procedure(const AEstado: TLicencaEstado);

  TLicencaController = class
  private
    const URL_GIL_STATUS = 'http://localhost:9000/licencas/status'; // Ajuste sua URL/Porta aqui
  public
    class procedure ValidarLicencaAssincrono(const ACNPJ: string; ACallback: TOnValidarLicencaProc);
  end;

implementation

{ TLicencaController }

class procedure TLicencaController.ValidarLicencaAssincrono(const ACNPJ: string; ACallback: TOnValidarLicencaProc);
begin
  // Executa a requisição HTTP em background (Thread paralela) para não congelar o FMX
  TTask.Run(
    procedure
    var
      LHttpClient: THTTPClient;
      LResponse: IHTTPResponse;
      LJson: TJSONObject;
      LEstado: TLicencaEstado;
    begin
      LHttpClient := THTTPClient.Create;
      try
        // Configura autenticação básica do seu servidor Horse se necessário
        LHttpClient.CustomHeaders['Authorization'] := 'Basic aW50ZWxsaXNvZnRHSUw6RzFsMjAyNg=='; // intellisoftGIL:G1l2026

        try
          // Faz a consulta enviando o parâmetro do cliente (Ex: CNPJ)
          LResponse := LHttpClient.Get(URL_GIL_STATUS + '?cnpj=' + ACNPJ);

          if LResponse.StatusCode = 200 then
          begin
            LJson := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONObject;
            if Assigned(LJson) then
            begin
              try
                // Captura as chaves tratadas no faturamento
                if LJson.GetValue<string>('status', '').Equals('ATIVA') then
                  LEstado.Status := lsAtiva
                else
                  LEstado.Status := lsBloqueada;

                LEstado.DiasRestantes   := LJson.GetValue<Integer>('diasRestantes', 0);
                LEstado.SomenteLeitura := LJson.GetValue<Boolean>('somenteLeitura', False);
                LEstado.PixCopiaCola    := LJson.GetValue<string>('pixCopiaCola', '');
                LEstado.PixQrCodeBase64 := LJson.GetValue<string>('pixQrCodeBase64', '');
                LEstado.Mensagem        := LJson.GetValue<string>('mensagem', '');
              finally
                LJson.Free;
              end;
            end;
          end
          else
          begin
            LEstado.Status := lsErro;
            LEstado.Mensagem := 'Não foi possível validar as credenciais do servidor.';
            LEstado.SomenteLeitura := True;
          end;

        except
          on E: Exception do
          begin
            LEstado.Status := lsErro;
            LEstado.Mensagem := 'Servidor de licenças indisponível: ' + E.Message;
            LEstado.SomenteLeitura := True; // Prevenção: caiu a internet, entra em contingência/leitura
          end;
        end;

        // Retorna o resultado de volta para a MainThread (Thread Principal da Interface UI)
        TThread.Synchronize(nil,
          procedure
          begin
            if Assigned(ACallback) then
              ACallback(LEstado);
          end);

      finally
        LHttpClient.Free;
      end;
    end);
end;

end.
