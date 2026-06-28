unit srvIntellisoft_GIL.controller.Modulos;

interface

uses
  Horse, System.JSON, System.SysUtils, DataSet.Serialize,
  srvIntellisof_GIL.service.Modulos;

procedure Registry;

implementation

procedure ListarModulos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectModulos;
begin
  Service := TdmGILConnectModulos.Create(nil);
  try Res.Send(Service.ListarTodos.ToJSONArray()); finally Service.Free; end;
end;

procedure ObterModulo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectModulos;
begin
  Service := TdmGILConnectModulos.Create(nil);
  try
    if not Service.ListarPorId(Req.Params['id'].ToInt64).IsEmpty then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject())
    else
      Res.Status(THTTPStatus.NotFound).Send('Módulo não encontrado.');
  finally Service.Free; end;
end;

procedure SalvarModulo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectModulos; LBody: TJSONObject;
begin
  Service := TdmGILConnectModulos.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) and Service.Inserir(LBody) then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.Created)
    else
      Res.Status(THTTPStatus.BadRequest).Send('Erro ao salvar ou JSON inválido.');
  finally Service.Free; end;
end;

procedure AtualizarModulo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectModulos; LBody: TJSONObject;
begin
  Service := TdmGILConnectModulos.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) and Service.Atualizar(Req.Params['id'].ToInt64, LBody) then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.OK)
    else
      Res.Status(THTTPStatus.BadRequest).Send('Erro ao atualizar módulo.');
  finally Service.Free; end;
end;

procedure ExcluirModulo(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectModulos;
begin
  Service := TdmGILConnectModulos.Create(nil);
  try
    if Service.Deletar(Req.Params['id'].ToInt64) then
      Res.Status(THTTPStatus.NoContent).Send('')
    else
      Res.Status(THTTPStatus.InternalServerError).Send('Erro ao excluir módulo.');
  finally Service.Free; end;
end;

procedure Registry;
begin
  THorse.Get('/modulos', ListarModulos);
  THorse.Get('/modulos/:id', ObterModulo);
  THorse.Post('/modulos', SalvarModulo);
  THorse.Put('/modulos/:id', AtualizarModulo);
  THorse.Delete('/modulos/:id', ExcluirModulo);
end;

end.
