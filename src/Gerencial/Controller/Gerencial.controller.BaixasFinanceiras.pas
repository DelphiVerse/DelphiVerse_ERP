unit Gerencial.controller.BaixasFinanceiras;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.NetEncoding,
  System.Classes,

  REST.Json,

  Gerencial.model.BaixasFinanceiras,
  untConstantes,
  untLibrary;

type
  TBaixasFinanceirasController = class
  private
    FHTTPClient: TNetHTTPClient;
    FBaseURL: string;
  public
    constructor Create;
    destructor Destroy; override;

    function Salvar(ABaixa: TBaixasFinanceirasModel; out Erro: string): Boolean;
    function Excluir(AId: Int64; out Erro: string): Boolean;
    function ListarPorLancamento(ALancamentoId: Int64; out Erro: string): TJSONArray;
    function CarregarPorId(AId: Int64): TBaixasFinanceirasModel;
    function Atualizar(ABaixa: TBaixasFinanceirasModel): Boolean;
  end;

implementation

{ TBaixasFinanceirasController }

function TBaixasFinanceirasController.Atualizar(ABaixa: TBaixasFinanceirasModel): Boolean;
var
  LResponse: IHTTPResponse;
  LSource: TStringStream;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  LSource := TStringStream.Create(TJson.ObjectToJsonString(ABaixa));
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
      // Ajuste conforme a rota PUT que o seu servidor Horse espera para atualizar
      LResponse := FHTTPClient.Put(FBaseURL + '/baixas/' + ABaixa.Id.ToString, LSource);

      if (LResponse.StatusCode in [200, 204]) then
        Result := True
      else
        Tlibrary.GravarLog('Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString);
    except
      on E: Exception do
        Tlibrary.GravarLog('Falha ao atualizar baixa: ' + E.Message);
    end;
  finally
    LSource.Free;
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TBaixasFinanceirasController.CarregarPorId(AId: Int64): TBaixasFinanceirasModel;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := nil;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
    // Rota GET /baixas/:id conforme seu controller servidor
    LResponse := FHTTPClient.Get(FBaseURL + '/baixas/' + AId.ToString);

    if LResponse.StatusCode = 200 then
      Result := TJson.JsonToObject<TBaixasFinanceirasModel>(LResponse.ContentAsString)
    else
      Tlibrary.GravarLog('Falha ao carregar baixa: ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString);
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

constructor TBaixasFinanceirasController.Create;
begin
  FHTTPClient := TNetHTTPClient.Create(nil);
  FBaseURL := 'http://localhost:9096'; // Ajuste conforme porta do seu Horse
end;

destructor TBaixasFinanceirasController.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TBaixasFinanceirasController.ListarPorLancamento(ALancamentoId: Int64; out Erro: string): TJSONArray;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := nil;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
      FHTTPClient.ContentType := 'application/json';

      // Ajustado exatamente para a sua rota aninhada: /lancamentos/:id/baixas
      LResponse := FHTTPClient.Get(FBaseURL + '/lancamentos/' + ALancamentoId.ToString + '/baixas');

      if (LResponse.StatusCode = 200) then
        Result := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONArray
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha ao listar histórico de baixas: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TBaixasFinanceirasController.Salvar(ABaixa: TBaixasFinanceirasModel; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LSource: TStringStream;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  LSource := TStringStream.Create(TJson.ObjectToJsonString(ABaixa));
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;

      // Alinhado com a sua rota POST /baixas
      if ABaixa.Id = 0 then
        LResponse := FHTTPClient.Post(FBaseURL + '/baixas', LSource)
      else
        LResponse := FHTTPClient.Put(FBaseURL + '/baixas' + ABaixa.Id.ToString, LSource);

      if (LResponse.StatusCode in [200, 201, 204]) then
      begin
        Tlibrary.GravarLog(LResponse.ContentAsString());
        Result := True;
      end
      else
      begin
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
        Tlibrary.GravarLog(Erro);
      end;
    except
      on E: Exception do
      begin
        Erro := 'Falha ao processar baixa financeira: ' + E.Message;
        Tlibrary.GravarLog(Erro);
      end;
    end;
  finally
    LSource.Free;
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TBaixasFinanceirasController.Excluir(AId: Int64; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;

      // Alinhado com a sua rota DELETE /baixas/:id
      LResponse := FHTTPClient.Delete(FBaseURL + '/baixas/' + AId.ToString);

      if (LResponse.StatusCode in [200, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha ao estornar baixa: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

end.
