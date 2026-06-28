unit Gerencial.controller.Modulos;

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
  Gerencial.model.Modulos,
  untConstantes;

type
  TModuloController = class
  private
    FHTTPClient: TNetHTTPClient;
    FBaseURL: string;
  public
    constructor Create;
    destructor Destroy; override;

    function Salvar(AModulo: TModuloModel; out Erro: string): Boolean;
    function Excluir(AId: Integer; out Erro: string): Boolean;
    function ListarTodos(out Erro: string): TJSONArray;
    function CarregarPorId(AId: Integer; out Erro: string): TModuloModel;
    function GetNomePorId(AId: Integer; out Erro: string): string;
  end;

implementation

{ TModuloController }

constructor TModuloController.Create;
begin
  FHTTPClient := TNetHTTPClient.Create(nil);
  FBaseURL := 'http://localhost:9096'; // Alinhar com a porta da sua API Horse
end;

destructor TModuloController.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TModuloController.CarregarPorId(AId: Integer; out Erro: string): TModuloModel;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := nil;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
    LResponse := FHTTPClient.Get(FBaseURL + '/modulos/' + AId.ToString);

    if LResponse.StatusCode = 200 then
      Result := TJson.JsonToObject<TModuloModel>(LResponse.ContentAsString)
    else
      Erro := 'Erro ao buscar módulo: ' + LResponse.StatusCode.ToString;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TModuloController.GetNomePorId(AId: Integer; out Erro: string): string;
var
  LResponse: IHTTPResponse;
  LAuth: string;
  LModelModulo: TModuloModel;
begin
  Result := '';
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
    LResponse := FHTTPClient.Get(FBaseURL + '/modulos/' + AId.ToString);
    LModelModulo:= TModuloModel.Create;
    if LResponse.StatusCode = 200 then
    begin
      LModelModulo:= TJson.JsonToObject<TModuloModel>(LResponse.ContentAsString);
      Result := LModelModulo.Nome;
    end
    else
      Erro := 'Erro ao buscar módulo: ' + LResponse.StatusCode.ToString;
  finally
    LModelModulo.Free;
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TModuloController.ListarTodos(out Erro: string): TJSONArray;
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

      LResponse := FHTTPClient.Get(FBaseURL + '/modulos');

      if (LResponse.StatusCode = 200) then
        Result := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONArray
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;

    except
      on E: Exception do
        Erro := 'Falha na comunicação ao listar módulos: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TModuloController.Salvar(AModulo: TModuloModel; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LSource: TStringStream;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  LSource := TStringStream.Create(TJson.ObjectToJsonString(AModulo));
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;

      if AModulo.Id = 0 then
        LResponse := FHTTPClient.Post(FBaseURL + '/modulos', LSource)
      else
        LResponse := FHTTPClient.Put(FBaseURL + '/modulos/' + AModulo.Id.ToString, LSource);

      if (LResponse.StatusCode in [200, 201, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;

    except
      on E: Exception do
        Erro := 'Falha na comunicação ao salvar: ' + E.Message;
    end;
  finally
    LSource.Free;
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TModuloController.Excluir(AId: Integer; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
      LResponse := FHTTPClient.Delete(FBaseURL + '/modulos/' + AId.ToString);

      if (LResponse.StatusCode in [200, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha na comunicação ao excluir: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

end.
