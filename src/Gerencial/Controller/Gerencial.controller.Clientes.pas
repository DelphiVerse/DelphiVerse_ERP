unit Gerencial.controller.Clientes;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.JSON,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.NetEncoding,
  System.Classes,

  Rest.Json,

  Gerencial.model.Clientes,
  DataSet.Serialize,
  untConstantes;

type
  TClienteController = class
  private
    FHTTPClient: TNetHTTPClient;
    FBaseURL: string;
  public
    constructor Create;
    destructor Destroy; override;

    function Salvar(ACliente: TClienteModel; out Erro: string): Boolean;
    function Excluir(AId: Integer; out Erro: string): Boolean;
    function ListarTodos(out Erro: string): TJSONArray;
    function CarregarPorId(AId: Integer; out Erro: string): TClienteModel;
    function GetNomePorId(AId: Integer; out Erro: string): string;
  end;

implementation

{ TClienteController }



{ TClienteController }

function TClienteController.CarregarPorId(AId: Integer; out Erro: string): TClienteModel;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := nil;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
    // Busca apenas o cliente específico pelo ID
    LResponse := FHTTPClient.Get(FBaseURL + '/clientes/' + AId.ToString);

    if LResponse.StatusCode = 200 then
      Result := TJson.JsonToObject<TClienteModel>(LResponse.ContentAsString)
    else
      Erro := 'Erro ao buscar cliente: ' + LResponse.StatusCode.ToString;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TClienteController.GetNomePorId(AId: Integer; out Erro: string): string;
var
  LResponse: IHTTPResponse;
  LAuth: string;
  LModelCliente: TClienteModel;
begin
  Result := '';
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
    // Busca apenas o cliente específico pelo ID
    LResponse := FHTTPClient.Get(FBaseURL + '/clientes/' + AId.ToString);
    LModelCliente:= TClienteModel.Create;
    if LResponse.StatusCode = 200 then
    begin
      LModelCliente:= TJson.JsonToObject<TClienteModel>(LResponse.ContentAsString);
      Result := LModelCliente.RazaoSocial;
    end
    else
      Erro := 'Erro ao buscar cliente: ' + LResponse.StatusCode.ToString;
  finally
    LModelCliente.Free;
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

constructor TClienteController.Create;
begin
  FHTTPClient := TNetHTTPClient.Create(nil);
  FBaseURL := 'http://localhost:9096';
end;

destructor TClienteController.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TClienteController.Excluir(AId: Integer; out Erro: string): Boolean;
begin

end;

function TClienteController.ListarTodos(out Erro: string): TJSONArray;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := nil;
  // Prepara a autenticação Base64 conforme seu padrão
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);

  try
    try
      // Configura o Header de Autorização[cite: 3]
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
      FHTTPClient.ContentType := 'application/json';

      // Executa a requisição GET para buscar os clientes
      LResponse := FHTTPClient.Get(FBaseURL + '/clientes');

      if (LResponse.StatusCode = 200) then
      begin
        // Converte a string de resposta em um TJSONArray para a View consumir
        Result := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONArray;
      end
      else
      begin
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
      end;

    except
      on E: Exception do
        Erro := 'Falha na comunicação ao listar: ' + E.Message;
    end;
  finally
    // Limpa o Header de autorização para as próximas chamadas[cite: 3]
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TClienteController.Salvar(ACliente: TClienteModel;
  out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LSource: TStringStream;
  LAuth: string;
begin
  Result := False;
  LAuth:= TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  LSource := TStringStream.Create(TJson.ObjectToJsonString(ACliente));
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
      if ACliente.Id = 0 then
        LResponse := FHTTPClient.Post(FBaseURL + '/clientes', LSource)
      else
        LResponse := FHTTPClient.Put(FBaseURL + '/clientes/' + ACliente.Id.ToString, LSource);

      if (LResponse.StatusCode in [200, 201, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;

    except
      on E: Exception do
        Erro := 'Falha na comunicação: ' + E.Message;
    end;
  finally
    LSource.Free;
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

end.
