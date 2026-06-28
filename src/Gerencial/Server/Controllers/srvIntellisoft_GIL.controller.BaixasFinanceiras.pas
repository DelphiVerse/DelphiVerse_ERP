unit srvIntellisoft_GIL.controller.BaixasFinanceiras;

interface

uses
  Horse,
  DataSet.Serialize,

  System.JSON,
  System.SysUtils,

  Data.DB,

  srvIntellisof_GIL.service.BaixasFinanceiras;

procedure Registry;

implementation

procedure ListarBaixasDoLancamento(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectBaixasFinanceiras;
begin
  Service := TdmGILConnectBaixasFinanceiras.Create(nil);
  try
    Res.Send(Service.ListarPorLancamento(Req.Params['id'].ToInt64).ToJSONArray());
  finally
    Service.Free;
  end;
end;

procedure ObterBaixa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectBaixasFinanceiras;
begin
  Service := TdmGILConnectBaixasFinanceiras.Create(nil);
  try
    if not Service.ListarPorId(Req.Params['id'].ToInt64).IsEmpty then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject())
    else
      Res.Status(THTTPStatus.NotFound).Send('Baixa financeira não encontrada.');
  finally
    Service.Free;
  end;
end;

procedure SalvarBaixa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectBaixasFinanceiras; LBody: TJSONObject;
begin
  Service := TdmGILConnectBaixasFinanceiras.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) then
    begin
      try
        if Service.Inserir(LBody) then
          Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.Created)
        else
          Res.Status(THTTPStatus.BadRequest).Send('Erro desconhecido ao processar baixa.');
      except
        on E: Exception do
          Res.Status(THTTPStatus.InternalServerError).Send('Erro: ' + E.Message);
      end;
    end
    else
      Res.Status(THTTPStatus.BadRequest).Send('Payload vazio ou inválido.');
  finally
    Service.Free;
  end;
end;

procedure AtualizarBaixa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectBaixasFinanceiras; LBody: TJSONObject;
begin
  Service := TdmGILConnectBaixasFinanceiras.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) then
    begin
      try
        if Service.Atualizar(Req.Params['id'].ToInt64, LBody) then
          Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.OK)
        else
          Res.Status(THTTPStatus.BadRequest).Send('Erro ao atualizar a baixa financeira.');
      except
        on E: Exception do
          Res.Status(THTTPStatus.InternalServerError).Send('Erro ao atualizar: ' + E.Message);
      end;
    end
    else
      Res.Status(THTTPStatus.BadRequest).Send('Payload vazio ou inválido.');
  finally
    Service.Free;
  end;
end;

procedure ExcluirBaixa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectBaixasFinanceiras;
begin
  Service := TdmGILConnectBaixasFinanceiras.Create(nil);
  try
    try
      if Service.Deletar(Req.Params['id'].ToInt64) then
        Res.Status(THTTPStatus.NoContent).Send('')
      else
        Res.Status(THTTPStatus.BadRequest).Send('Não foi possível excluir a baixa financeira.');
    except
      on E: Exception do
        Res.Status(THTTPStatus.InternalServerError).Send('Erro ao estornar: ' + E.Message);
    end;
  finally
    Service.Free;
  end;
end;

procedure Registry;
begin
  // Rota para listar o histórico de baixas de uma conta específica
  THorse.Get('/lancamentos/:id/baixas', ListarBaixasDoLancamento);

  // Rotas CRUD padrão da Baixa em si
  THorse.Get('/baixas/:id', ObterBaixa);
  THorse.Post('/baixas', SalvarBaixa);
  THorse.Put('/baixas/:id', AtualizarBaixa);
  THorse.Delete('/baixas/:id', ExcluirBaixa);
end;

end.
