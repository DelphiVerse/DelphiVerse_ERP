unit Gerencial.controller.LancamentosFinanceiros;

interface

uses
  System.SysUtils,
  System.JSON,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.NetEncoding,
  System.Classes,

  REST.Json,

  Gerencial.model.LancamentosFinanceiros,
  untConstantes;

type
  TLancamentosController = class
  private
    FHTTPClient: TNetHTTPClient;
    FBaseURL: string;
  public
    constructor Create;
    destructor Destroy; override;

    function Salvar(ALancamento: TLancamentosModel; out Erro: string): Boolean;
    function Excluir(AId: Int64; out Erro: string): Boolean;
    function ListarTodos(out Erro: string): TJSONArray;
    function CarregarPorId(AId: Int64; out Erro: string): TLancamentosModel;
  end;

implementation

{ TLancamentosController }

constructor TLancamentosController.Create;
begin
  FHTTPClient := TNetHTTPClient.Create(nil);
  FBaseURL := 'http://localhost:9096';
end;

destructor TLancamentosController.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TLancamentosController.CarregarPorId(AId: Int64; out Erro: string): TLancamentosModel;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := nil;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
    LResponse := FHTTPClient.Get(FBaseURL + '/lancamentos/' + AId.ToString);

    if LResponse.StatusCode = 200 then
      Result := TJson.JsonToObject<TLancamentosModel>(LResponse.ContentAsString)
    else
      Erro := 'Erro ao buscar lançamento financeiro: ' + LResponse.StatusCode.ToString;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TLancamentosController.ListarTodos(out Erro: string): TJSONArray;
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
      LResponse := FHTTPClient.Get(FBaseURL + '/lancamentos');

      if (LResponse.StatusCode = 200) then
        Result := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONArray
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha ao listar lançamentos financeiros: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TLancamentosController.Salvar(ALancamento: TLancamentosModel; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LSource: TStringStream;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  LSource := TStringStream.Create(TJson.ObjectToJsonString(ALancamento));
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
      if ALancamento.Id = 0 then
        LResponse := FHTTPClient.Post(FBaseURL + '/lancamentos', LSource)
      else
        LResponse := FHTTPClient.Put(FBaseURL + '/lancamentos/' + ALancamento.Id.ToString, LSource);

      if (LResponse.StatusCode in [200, 201, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha ao salvar lançamento financeiro: ' + E.Message;
    end;
  finally
    LSource.Free;
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TLancamentosController.Excluir(AId: Int64; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
      LResponse := FHTTPClient.Delete(FBaseURL + '/lancamentos/' + AId.ToString);

      if (LResponse.StatusCode in [200, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha ao excluir lançamento financeiro: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

end.
