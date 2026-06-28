unit Gerencial.controller.Licenca;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.JSON,
  System.Net.HttpClient,
  System.Net.HttpClientComponent,
  System.NetEncoding,
  System.Classes,

  REST.Json,
  Gerencial.model.Licenca,
  untConstantes;

type
  TLicencaController = class
  private
    FHTTPClient: TNetHTTPClient;
    FBaseURL: string;
  public
    constructor Create;
    destructor Destroy; override;

    function Salvar(ALicenca: TLicencaModel; out Erro: string): Boolean;
    function Excluir(AId: Integer; out Erro: string): Boolean;
    function ListarTodas(out Erro: string): TJSONArray;
    function CarregarPorId(AId: Integer; out Erro: string): TLicencaModel;
  end;

implementation

{ TLicencaController }

constructor TLicencaController.Create;
begin
  FHTTPClient := TNetHTTPClient.Create(nil);
  FBaseURL := 'http://localhost:9096';
end;

destructor TLicencaController.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TLicencaController.CarregarPorId(AId: Integer; out Erro: string): TLicencaModel;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := nil;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
    LResponse := FHTTPClient.Get(FBaseURL + '/licencas/' + AId.ToString);

    if LResponse.StatusCode = 200 then
      Result := TJson.JsonToObject<TLicencaModel>(LResponse.ContentAsString)
    else
      Erro := 'Erro ao buscar licença: ' + LResponse.StatusCode.ToString;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TLicencaController.ListarTodas(out Erro: string): TJSONArray;
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

      LResponse := FHTTPClient.Get(FBaseURL + '/licencas');

      if (LResponse.StatusCode = 200) then
        Result := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONArray
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha na comunicação ao listar licenças: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TLicencaController.Salvar(ALicenca: TLicencaModel; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LSource: TStringStream;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  LSource := TStringStream.Create(TJson.ObjectToJsonString(ALicenca));
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;

      if ALicenca.Id = 0 then
        LResponse := FHTTPClient.Post(FBaseURL + '/licencas', LSource)
      else
        LResponse := FHTTPClient.Put(FBaseURL + '/licencas/' + ALicenca.Id.ToString, LSource);

      if (LResponse.StatusCode in [200, 201, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha na comunicação ao salvar licença: ' + E.Message;
    end;
  finally
    LSource.Free;
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TLicencaController.Excluir(AId: Integer; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
      LResponse := FHTTPClient.Delete(FBaseURL + '/licencas/' + AId.ToString);

      if (LResponse.StatusCode in [200, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha na comunicação ao excluir licença: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

end.
