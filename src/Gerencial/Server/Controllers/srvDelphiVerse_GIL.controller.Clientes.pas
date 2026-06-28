unit srvDelphiVerse_GIL.controller.Clientes;

interface

uses
  Horse,
  Horse.Jhonson,
  Horse.Documentation,
  Horse.Documentation.OpenApi.Interfaces,
  Horse.Documentation.OpenApi.Types,

  System.JSON,
  System.SysUtils,

  Data.DB,

  DataSet.Serialize,

  ServerGIL.providers.ProviderConnection,
  srvDelphiVerse_GIL.service.Clientes,
  untLibrary;

procedure Registry;

implementation

procedure ListarClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Service: TdmGILConnectClientes;
  Connection: TdmGILConnect;
  lJSONArray: TJSONArray;
begin
  Writeln('Listando clientes...');
  Connection := TdmGILConnect.Create(nil);
  Service := TdmGILConnectClientes.Create(nil);
  try
    lJSONArray:= Service.ListarTodos.ToJSONArray();
    Tlibrary.GravarLog('ListarClientes -> JSON Gerado: ' + lJSONArray.ToString);
    Res.Send(lJSONArray);
  finally
    Service.Free;
    Connection.Free;
  end;
end;

procedure ObterCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Service: TdmGILConnectClientes;
  Connection: TdmGILConnect;
  lJSONObject: TJSONObject;
begin
  Connection := TdmGILConnect.Create(nil);
  Service := TdmGILConnectClientes.Create(nil);
  try
    if Service.ListarPorId(Req.Params['id'].ToInt64).IsEmpty then
      raise EHorseException.New
        .Status(THTTPStatus.NotFound)
        .Error('Cliente não encontrado');
    lJSONObject:= Service.qryAux.ToJSONObject();
    Tlibrary.GravarLog('ObterClientes -> ID: ' + IntToStr(Req.Params['id'].ToInt64) + ' -> JSON Gerado: ' + lJSONObject.ToString);
    Res.Send<TJSONObject>(lJSONObject);
  finally
    Service.Free;
    Connection.Free;
  end;
end;

procedure SalvarCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Service: TdmGILConnectClientes;
  LBody: TJSONObject;
begin
  Service := TdmGILConnectClientes.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;

    if Assigned(LBody) and (LBody.Count > 0) then
    begin
      if Service.Inserir(LBody) then
      begin
        Tlibrary.GravarLog('SalvarCliente -> Sucesso');
        Res.Send<TJSONObject>(Service.qryCadastro.ToJSONObject()).Status(THTTPStatus.Created);
      end
      else
      begin
        Tlibrary.GravarLog('SalvarCliente -> Falha na consistência dos bancos');
        Res.Status(THTTPStatus.InternalServerError).Send('Erro ao inserir no banco.');
      end;
    end
    else
    begin
      Tlibrary.GravarLog('Corpo da requisição vazio ou inválido.');
      Res.Status(THTTPStatus.BadRequest).Send('Corpo da requisição vazio ou inválido.');
    end;

  finally
    Service.Free;
  end;
end;

procedure ExcluirCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Service: TdmGILConnectClientes;
  lId: Int64;
begin
  Service := TdmGILConnectClientes.Create(nil);
  try
    lId:= Req.Params['id'].ToInt64;
    if Service.Deletar(lId) then
    begin
      Tlibrary.GravarLog('ExcluirCliente -> ID: ' + LId.ToString + ' -> Sucesso');
      Res.Status(THTTPStatus.NoContent).Send('');
    end
    else
    begin
      raise EHorseException.New
        .Status(THTTPStatus.NotFound)
        .Error('Cliente não encontrado');
    end;
  finally
    Service.Free;
  end;
end;

procedure AtualizarCliente(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Service: TdmGILConnectClientes;
  Connection: TdmGILConnect;
  LBody: TJSONObject;
  LId: Int64;
begin
  Connection := TdmGILConnect.Create(nil);
  Service := TdmGILConnectClientes.Create(nil);
  LId := Req.Params['id'].ToInt64;
  LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
  try
    if Assigned(LBody) then
    begin
      // Adicionamos o ID ao JSON para garantir que o Service saiba qual registro alterar
      LBody.AddPair('id', TJSONNumber.Create(LId));

      if Service.Atualizar(LId, LBody) then // Supondo que seu Service tenha o método Editar
      begin
        Tlibrary.GravarLog('AtualizarCliente -> ID: ' + LId.ToString + ' -> Sucesso');
        Res.Send<TJSONObject>(Service.qryCadastro.ToJSONObject()).Status(THTTPStatus.OK);
      end
      else
      begin
        Tlibrary.GravarLog('AtualizarCliente -> ID: ' + LId.ToString + ' -> Falha ao editar');
        Res.Status(THTTPStatus.InternalServerError).Send('Erro ao atualizar no banco de dados.');
      end;
    end
    else
      Res.Status(THTTPStatus.BadRequest).Send('Corpo da requisição inválido.');

  finally
    Service.Free;
    Connection.Free;
    if Assigned(LBody) then
      LBody.Free;
  end;
end;

procedure Registry;
begin
  // 2. Adicionando uma Tag para agrupar endpoints
  HorseDoc.Tags.Add
    .Name('Clientes')
    .Description('Operações relacionadas aos clientes');

  // 3. Documentando um endpoint GET para buscar um usuário por ID
  HorseDoc.Paths.Add('/clientes') // Adiciona o caminho
    .Get // Define a operação como GET
      .Tags.Add('clientes') // Associa a tag 'Users'
      .Summary('Obter todos os clientes')
      .Description('Retorna todos os clientes cadastrados.')
      .Responses // Começa a definir as respostas
        .StatusCodes.Add('200') // Resposta para o status 200 (OK)
          .Description('Clientes encontrados com sucesso')
          .Content.Add('application/json')
            .Schema(TJSONObject.Create.AddPair('$ref', '#/components/schemas/clientes'))
            .&End
          .&End // Finaliza a resposta 200
        .StatusCodes.Add('404')
          .Description('Cliente não encontrado')
          .&End;

  // 4. Definindo um Schema reutilizável em 'Components'
  HorseDoc.Components.Schemas.Add('clientes',
    TJSONObject.Create
      .AddPair('type', 'object')
      .AddPair('properties', TJSONObject.Create
          .AddPair('id', TJSONObject.Create.AddPair('type', 'integer'))
          .AddPair('name', TJSONObject.Create.AddPair('type', 'string'))
          .AddPair('email', TJSONObject.Create.AddPair('type', 'string'))
      )
  );

  THorse.Get('/clientes', ListarClientes);
  THorse.Get('/clientes/:id', ObterCliente);
  THorse.Post('/clientes', SalvarCliente);
  THorse.Put('/clientes/:id', AtualizarCliente);
  THorse.Delete('/clientes/:id', ExcluirCliente);
end;

end.
