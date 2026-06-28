unit srvIntellisoft_GIL.controller.Planos;

interface

uses
  Horse,

  System.JSON,
  System.SysUtils,

  DataSet.Serialize,

  srvIntellisof_GIL.service.Planos,
  untLibrary;

procedure Registry;

implementation

procedure ListarPlanos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Service: TdmGILConnectPlanos;
  lJSONArray: TJSONArray;
begin
  Service := TdmGILConnectPlanos.Create(nil);
  try
    lJSONArray:= Service.ListarTodos.ToJSONArray();
    Tlibrary.GravarLog('ListarClientes -> JSON Gerado: ' + lJSONArray.ToString);
    Res.Send(lJSONArray);
  finally
    Service.Free;
  end;
end;

procedure ObterPlano(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectPlanos;
begin
  Service := TdmGILConnectPlanos.Create(nil);
  try
    if not Service.ListarPorId(Req.Params['id'].ToInt64).IsEmpty then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject())
    else
      Res.Status(THTTPStatus.NotFound).Send('Plano não encontrado.');
  finally Service.Free; end;
end;

procedure SalvarPlano(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectPlanos; LBody: TJSONObject;
begin
  Service := TdmGILConnectPlanos.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) and Service.Inserir(LBody) then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.Created)
    else
      Res.Status(THTTPStatus.BadRequest).Send('Erro ao salvar ou JSON inválido.');
  finally
    Service.Free;
  end;
end;

procedure AtualizarPlano(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectPlanos; LBody: TJSONObject;
begin
  Service := TdmGILConnectPlanos.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) and Service.Atualizar(Req.Params['id'].ToInt64, LBody) then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.OK)
    else
      Res.Status(THTTPStatus.BadRequest).Send('Erro ao atualizar plano.');
  finally Service.Free; end;
end;

procedure ExcluirPlano(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectPlanos;
begin
  Service := TdmGILConnectPlanos.Create(nil);
  try
    if Service.Deletar(Req.Params['id'].ToInt64) then
      Res.Status(THTTPStatus.NoContent).Send('')
    else
      Res.Status(THTTPStatus.InternalServerError).Send('Erro ao excluir plano.');
  finally Service.Free; end;
end;

procedure Registry;
begin
  THorse.Get('/planos', ListarPlanos);
  THorse.Get('/planos/:id', ObterPlano);
  THorse.Post('/planos', SalvarPlano);
  THorse.Put('/planos/:id', AtualizarPlano);
  THorse.Delete('/planos/:id', ExcluirPlano);
end;

end.
