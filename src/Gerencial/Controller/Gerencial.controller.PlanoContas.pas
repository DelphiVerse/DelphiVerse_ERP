unit Gerencial.controller.PlanoContas;

interface

uses
  System.SysUtils, System.JSON, System.Net.HttpClient, System.Net.HttpClientComponent,
  System.NetEncoding, System.Classes, REST.Json, Gerencial.model.PlanoContas, untConstantes;

type
  TPlanoContasController = class
  private
    FHTTPClient: TNetHTTPClient;
    FBaseURL: string;
  public
    constructor Create;
    destructor Destroy; override;

    function Salvar(APlanoConta: TPlanoContasModel; out Erro: string): Boolean;
    function Excluir(AId: Int64; out Erro: string): Boolean;
    function ListarTodos(out Erro: string): TJSONArray;
    function CarregarPorId(AId: Int64; out Erro: string): TPlanoContasModel;
  end;

implementation

{ TPlanoContasController }

constructor TPlanoContasController.Create;
begin
  FHTTPClient := TNetHTTPClient.Create(nil);
  FBaseURL := 'http://localhost:9096';
end;

destructor TPlanoContasController.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TPlanoContasController.CarregarPorId(AId: Int64; out Erro: string): TPlanoContasModel;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := nil;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
    LResponse := FHTTPClient.Get(FBaseURL + '/planocontas/' + AId.ToString);

    if LResponse.StatusCode = 200 then
      Result := TJson.JsonToObject<TPlanoContasModel>(LResponse.ContentAsString)
    else
      Erro := 'Erro ao buscar plano de conta: ' + LResponse.StatusCode.ToString;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TPlanoContasController.ListarTodos(out Erro: string): TJSONArray;
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
      LResponse := FHTTPClient.Get(FBaseURL + '/planocontas');

      if (LResponse.StatusCode = 200) then
        Result := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONArray
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha ao listar planos de contas: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TPlanoContasController.Salvar(APlanoConta: TPlanoContasModel; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LSource: TStringStream;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  LSource := TStringStream.Create(TJson.ObjectToJsonString(APlanoConta));
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
      if APlanoConta.Id = 0 then
        LResponse := FHTTPClient.Post(FBaseURL + '/planocontas', LSource)
      else
        LResponse := FHTTPClient.Put(FBaseURL + '/planocontas/' + APlanoConta.Id.ToString, LSource);

      if (LResponse.StatusCode in [200, 201, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha ao salvar plano de conta: ' + E.Message;
    end;
  finally
    LSource.Free;
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TPlanoContasController.Excluir(AId: Int64; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
      LResponse := FHTTPClient.Delete(FBaseURL + '/planocontas/' + AId.ToString);

      if (LResponse.StatusCode in [200, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha ao excluir plano de conta: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

end.
