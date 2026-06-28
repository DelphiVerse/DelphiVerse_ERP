unit srvDelphiVerse_GIL.controller.LancamentosFinanceiros;

interface

uses
  Horse,

  System.JSON,
  System.SysUtils,

  DataSet.Serialize,

  srvDelphiVerse_GIL.service.LancamentosFinanceiros;

procedure Registry;

implementation

procedure ListarLancamentos(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectLancFinanceiros;
begin
  Service := TdmGILConnectLancFinanceiros.Create(nil);
  try
    Res.Send(Service.ListarTodas.ToJSONArray());
  finally
    Service.Free;
  end;
end;

procedure ObterLancamento(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectLancFinanceiros;
begin
  Service := TdmGILConnectLancFinanceiros.Create(nil);
  try
    if not Service.ListarPorId(Req.Params['id'].ToInt64).IsEmpty then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject())
    else
      Res.Status(THTTPStatus.NotFound).Send('Lançamento não encontrado.');
  finally
    Service.Free;
  end;
end;

procedure SalvarLancamento(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectLancFinanceiros; LBody: TJSONObject;
begin
  Service := TdmGILConnectLancFinanceiros.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) and Service.Inserir(LBody) then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.Created)
    else
      Res.Status(THTTPStatus.BadRequest).Send('Erro ao salvar lançamento financeiro.');
  finally
    Service.Free;
  end;
end;

procedure AtualizarLancamento(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectLancFinanceiros; LBody: TJSONObject;
begin
  Service := TdmGILConnectLancFinanceiros.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) and Service.Atualizar(Req.Params['id'].ToInt64, LBody) then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.OK)
    else
      Res.Status(THTTPStatus.BadRequest).Send('Erro ao atualizar lançamento financeiro.');
  finally
    Service.Free;
  end;
end;

procedure ExcluirLancamento(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectLancFinanceiros;
begin
  Service := TdmGILConnectLancFinanceiros.Create(nil);
  try
    if Service.Deletar(Req.Params['id'].ToInt64) then
      Res.Status(THTTPStatus.NoContent).Send('')
    else
      Res.Status(THTTPStatus.InternalServerError).Send('Erro ao excluir lançamento.');
  finally
    Service.Free;
  end;
end;

procedure Registry;
begin
  THorse.Get('/lancamentos', ListarLancamentos);
  THorse.Get('/lancamentos/:id', ObterLancamento);
  THorse.Post('/lancamentos', SalvarLancamento);
  THorse.Put('/lancamentos/:id', AtualizarLancamento);
  THorse.Delete('/lancamentos/:id', ExcluirLancamento);
end;

end.
