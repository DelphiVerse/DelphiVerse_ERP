unit Gerencial.controller.Planos;

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
  Gerencial.model.Planos,
  untConstantes;

type
  TPlanoController = class
  private
    FHTTPClient: TNetHTTPClient;
    FBaseURL: string;
  public
    constructor Create;
    destructor Destroy; override;

    function Salvar(APlano: TPlanoModel; out Erro: string): Boolean;
    function Excluir(AId: Integer; out Erro: string): Boolean;
    function ListarTodos(out Erro: string): TJSONArray;
    function CarregarPorId(AId: Integer; out Erro: string): TPlanoModel;
    function GetNomePorId(AId: Integer; out Erro: string): string;
  end;

implementation

{ TPlanoController }

constructor TPlanoController.Create;
begin
  FHTTPClient := TNetHTTPClient.Create(nil);
  FBaseURL := 'http://localhost:9096'; // Alinhar com a porta da sua API Horse
end;

destructor TPlanoController.Destroy;
begin
  FHTTPClient.Free;
  inherited;
end;

function TPlanoController.CarregarPorId(AId: Integer; out Erro: string): TPlanoModel;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := nil;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
    LResponse := FHTTPClient.Get(FBaseURL + '/planos/' + AId.ToString);

    if LResponse.StatusCode = 200 then
      Result := TJson.JsonToObject<TPlanoModel>(LResponse.ContentAsString)
    else
      Erro := 'Erro ao buscar plano: ' + LResponse.StatusCode.ToString;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TPlanoController.GetNomePorId(AId: Integer; out Erro: string): string;
var
  LResponse: IHTTPResponse;
  LAuth: string;
  LPlanoModel: TPlanoModel;
begin
  Result := '';
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
    LResponse := FHTTPClient.Get(FBaseURL + '/planos/' + AId.ToString);
    LPlanoModel:= TPlanoModel.Create;
    if LResponse.StatusCode = 200 then
    begin
      LPlanoModel:= TJson.JsonToObject<TPlanoModel>(LResponse.ContentAsString);
      Result := LPlanoModel.Nome;
    end
    else
      Erro := 'Erro ao buscar plano: ' + LResponse.StatusCode.ToString;
  finally
    LPlanoModel.Free;
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TPlanoController.ListarTodos(out Erro: string): TJSONArray;
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

      LResponse := FHTTPClient.Get(FBaseURL + '/planos');

      if (LResponse.StatusCode = 200) then
        Result := TJSONObject.ParseJSONValue(LResponse.ContentAsString) as TJSONArray
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;

    except
      on E: Exception do
        Erro := 'Falha na comunicação ao listar planos: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TPlanoController.Salvar(APlano: TPlanoModel; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LSource: TStringStream;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  LSource := TStringStream.Create(TJson.ObjectToJsonString(APlano));
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;

      if APlano.Id = 0 then
        LResponse := FHTTPClient.Post(FBaseURL + '/planos', LSource)
      else
        LResponse := FHTTPClient.Put(FBaseURL + '/planos/' + APlano.Id.ToString, LSource);

      if (LResponse.StatusCode in [200, 201, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;

    except
      on E: Exception do
        Erro := 'Falha na comunicação ao salvar o plano: ' + E.Message;
    end;
  finally
    LSource.Free;
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

function TPlanoController.Excluir(AId: Integer; out Erro: string): Boolean;
var
  LResponse: IHTTPResponse;
  LAuth: string;
begin
  Result := False;
  LAuth := TNetEncoding.Base64.Encode(_USER_API + ':' + _PASSWORD_API);
  try
    try
      FHTTPClient.CustomHeaders['Authorization'] := 'Basic ' + LAuth;
      LResponse := FHTTPClient.Delete(FBaseURL + '/planos/' + AId.ToString);

      if (LResponse.StatusCode in [200, 204]) then
        Result := True
      else
        Erro := 'Erro ' + LResponse.StatusCode.ToString + ': ' + LResponse.ContentAsString;
    except
      on E: Exception do
        Erro := 'Falha na comunicação ao excluir o plano: ' + E.Message;
    end;
  finally
    FHTTPClient.CustomHeaders['Authorization'] := '';
  end;
end;

end.
