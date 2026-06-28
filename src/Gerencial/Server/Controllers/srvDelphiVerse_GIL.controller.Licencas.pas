unit srvDelphiVerse_GIL.controller.Licencas;

interface

uses
  Horse,

  System.JSON,
  System.SysUtils,

  DataSet.Serialize,

  srvDelphiVerse_GIL.service.Licencas;

procedure Registry;

implementation

procedure ListarLicencas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectLicencas;
begin
  Service := TdmGILConnectLicencas.Create(nil);
  try Res.Send(Service.ListarTodas.ToJSONArray()); finally Service.Free; end;
end;

procedure ObterLicenca(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectLicencas;
begin
  Service := TdmGILConnectLicencas.Create(nil);
  try
    if not Service.ListarPorId(Req.Params['id'].ToInt64).IsEmpty then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject())
    else
      Res.Status(THTTPStatus.NotFound).Send('Licença não encontrada.');
  finally Service.Free; end;
end;

procedure SalvarLicenca(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectLicencas; LBody: TJSONObject;
begin
  Service := TdmGILConnectLicencas.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) and Service.Inserir(LBody) then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.Created)
    else
      Res.Status(THTTPStatus.BadRequest).Send('Erro ao salvar licença.');
  finally Service.Free; end;
end;

procedure AtualizarLicenca(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectLicencas; LBody: TJSONObject;
begin
  Service := TdmGILConnectLicencas.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) and Service.Atualizar(Req.Params['id'].ToInt64, LBody) then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.OK)
    else
      Res.Status(THTTPStatus.BadRequest).Send('Erro ao atualizar licença.');
  finally Service.Free; end;
end;

procedure ExcluirLicenca(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectLicencas;
begin
  Service := TdmGILConnectLicencas.Create(nil);
  try
    if Service.Deletar(Req.Params['id'].ToInt64) then
      Res.Status(THTTPStatus.NoContent).Send('')
    else
      Res.Status(THTTPStatus.InternalServerError).Send('Erro ao excluir licença.');
  finally Service.Free; end;
end;

procedure Registry;
begin
  THorse.Get('/licencas', ListarLicencas);
  THorse.Get('/licencas/:id', ObterLicenca);
  THorse.Post('/licencas', SalvarLicenca);
  THorse.Put('/licencas/:id', AtualizarLicenca);
  THorse.Delete('/licencas/:id', ExcluirLicenca);
end;

end.
