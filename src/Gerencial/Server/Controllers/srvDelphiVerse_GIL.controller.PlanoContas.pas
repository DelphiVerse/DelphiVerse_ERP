unit srvDelphiVerse_GIL.controller.PlanoContas;

interface

uses
  Horse,

  System.JSON,
  System.SysUtils,

  DataSet.Serialize,

  srvDelphiVerse_GIL.service.PlanoContas;

procedure Registry;

implementation

procedure ListarPlanos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectPlanoContas;
begin
  Service := TdmGILConnectPlanoContas.Create(nil);
  try Res.Send(Service.ListarTodas.ToJSONArray()); finally Service.Free; end;
end;

procedure ObterPlano(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectPlanoContas;
begin
  Service := TdmGILConnectPlanoContas.Create(nil);
  try
    if not Service.ListarPorId(Req.Params['id'].ToInt64).IsEmpty then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject())
    else
      Res.Status(THTTPStatus.NotFound).Send('Plano de conta não encontrado.');
  finally Service.Free; end;
end;

procedure SalvarPlano(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectPlanoContas; LBody: TJSONObject;
begin
  Service := TdmGILConnectPlanoContas.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) and Service.Inserir(LBody) then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.Created)
    else
      Res.Status(THTTPStatus.BadRequest).Send('Erro ao salvar plano de conta.');
  finally Service.Free; end;
end;

procedure AtualizarPlano(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectPlanoContas; LBody: TJSONObject;
begin
  Service := TdmGILConnectPlanoContas.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) and Service.Atualizar(Req.Params['id'].ToInt64, LBody) then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.OK)
    else
      Res.Status(THTTPStatus.BadRequest).Send('Erro ao atualizar plano de conta.');
  finally Service.Free; end;
end;

procedure ExcluirPlano(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectPlanoContas;
begin
  Service := TdmGILConnectPlanoContas.Create(nil);
  try
    if Service.Deletar(Req.Params['id'].ToInt64) then
      Res.Status(THTTPStatus.NoContent).Send('')
    else
      Res.Status(THTTPStatus.InternalServerError).Send('Erro ao excluir plano de conta.');
  finally Service.Free; end;
end;

procedure Registry;
begin
  THorse.Get('/planocontas', ListarPlanos);
  THorse.Get('/planocontas/:id', ObterPlano);
  THorse.Post('/planocontas', SalvarPlano);
  THorse.Put('/planocontas/:id', AtualizarPlano);
  THorse.Delete('/planocontas/:id', ExcluirPlano);
end;

end.
