unit srvDelphiVerse_GIL.controller.CentroCustos;

interface

uses
  Horse, System.JSON, System.SysUtils, DataSet.Serialize,
  srvDelphiVerse_GIL.service.CentroCustos;

procedure Registry;

implementation

procedure ListarCentros(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectCentroCustos;
begin
  Service := TdmGILConnectCentroCustos.Create(nil);
  try Res.Send(Service.ListarTodas.ToJSONArray()); finally Service.Free; end;
end;

procedure ObterCentro(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectCentroCustos;
begin
  Service := TdmGILConnectCentroCustos.Create(nil);
  try
    if not Service.ListarPorId(Req.Params['id'].ToInt64).IsEmpty then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject())
    else
      Res.Status(THTTPStatus.NotFound).Send('Centro de custo não encontrado.');
  finally Service.Free; end;
end;

procedure SalvarCentro(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectCentroCustos; LBody: TJSONObject;
begin
  Service := TdmGILConnectCentroCustos.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) and Service.Inserir(LBody) then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.Created)
    else
      Res.Status(THTTPStatus.BadRequest).Send('Erro ao salvar centro de custo.');
  finally Service.Free; end;
end;

procedure AtualizarCentro(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectCentroCustos; LBody: TJSONObject;
begin
  Service := TdmGILConnectCentroCustos.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) and Service.Atualizar(Req.Params['id'].ToInt64, LBody) then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.OK)
    else
      Res.Status(THTTPStatus.BadRequest).Send('Erro ao atualizar centro de custo.');
  finally Service.Free; end;
end;

procedure ExcluirCentro(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectCentroCustos;
begin
  Service := TdmGILConnectCentroCustos.Create(nil);
  try
    if Service.Deletar(Req.Params['id'].ToInt64) then
      Res.Status(THTTPStatus.NoContent).Send('')
    else
      Res.Status(THTTPStatus.InternalServerError).Send('Erro ao excluir centro de custo.');
  finally Service.Free; end;
end;

procedure Registry;
begin
  THorse.Get('/centrocustos', ListarCentros);
  THorse.Get('/centrocustos/:id', ObterCentro);
  THorse.Post('/centrocustos', SalvarCentro);
  THorse.Put('/centrocustos/:id', AtualizarCentro);
  THorse.Delete('/centrocustos/:id', ExcluirCentro);
end;

end.
