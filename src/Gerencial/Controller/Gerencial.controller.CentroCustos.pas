unit Gerencial.controller.CentroCustos;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.NetEncoding,
  System.Classes,

  REST.Json,

  Gerencial.model.CentroCustos,
  untConstantes;

type
  TCentroCustosController = class
  private
    FHTTPClient: TNetHTTPClient;
    FBaseURL: string;
  public
    constructor Create;
    destructor Destroy; override;

    function Salvar(ACentroCusto: TCentroCustosModel; out Erro: string): Boolean;
    function Excluir(AId: Int64; out Erro: string): Boolean;
    function ListarTodos(out Erro: string): TJSONArray;
    function CarregarPorId(AId: Int64; out Erro: string): TCentroCustosModel;
  end;

implementation

{ TCentroCustosController }

constructor TCentroCustosController.Create;
begin
  FHTTPClient := TNetHTTPClient.Create(nil);
  FBaseURL := 'http://localhost:9096';
end;

destructor TCentroCustosController.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TCentroCustosController.CarregarPorId(AId: Int64; out Erro: string): TCentroCustosModel;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := nil;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
    LResponse := FHTTPClient.Get(FBaseURL + '/centrocustos/' + AId.ToString);

    if LResponse.StatusCode = 200 then
      Result := TJson.JsonToObject<TCentroCustosModel>(LResponse.ContentAsString)
    else
      Erro := 'Erro ao buscar centro de custo: ' + LResponse.StatusCode.ToString;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TCentroCustosController.ListarTodos(out Erro: string): TJSONArray;
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
      LResponse := FHTTPClient.Get(FBaseURL + '/centrocustos');

      if (LResponse.StatusCode = 200) then
        Result := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONArray
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha ao listar centro de custos: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TCentroCustosController.Salvar(ACentroCusto: TCentroCustosModel; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LSource: TStringStream;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  LSource := TStringStream.Create(TJson.ObjectToJsonString(ACentroCusto));
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
      if ACentroCusto.Id = 0 then
        LResponse := FHTTPClient.Post(FBaseURL + '/centrocustos', LSource)
      else
        LResponse := FHTTPClient.Put(FBaseURL + '/centrocustos/' + ACentroCusto.Id.ToString, LSource);

      if (LResponse.StatusCode in [200, 201, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha ao salvar centro de custo: ' + E.Message;
    end;
  finally
    LSource.Free;
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TCentroCustosController.Excluir(AId: Int64; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
      LResponse := FHTTPClient.Delete(FBaseURL + '/centrocustos/' + AId.ToString);

      if (LResponse.StatusCode in [200, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha ao excluir centro de custo: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

end.
