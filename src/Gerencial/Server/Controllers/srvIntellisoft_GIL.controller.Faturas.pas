unit srvIntellisoft_GIL.controller.Faturas;

interface

uses
  Horse,
  System.JSON,
  System.SysUtils,

  DataSet.Serialize,

  srvIntellisof_GIL.service.Faturas;

procedure Registry;

implementation

procedure ListarFaturas(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Service: TdmGILConnectFaturas;
  vClienteId: string;
begin
  Service := TdmGILConnectFaturas.Create(nil);
  try
    // Permite filtrar opcionalmente por cliente via QueryParam (?clienteId=X)
    if Req.Query.TryGetValue('clienteId', vClienteId) then
      Res.Send(Service.ListarPorCliente(vClienteId.ToInt64).ToJSONArray())
    else
      Res.Send(Service.ListarTodas.ToJSONArray());
  finally
    Service.Free;
  end;
end;

procedure ObterFatura(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectFaturas;
begin
  Service := TdmGILConnectFaturas.Create(nil);
  try
    if not Service.ListarPorId(Req.Params['id'].ToInt64).IsEmpty then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject())
    else
      Res.Status(THTTPStatus.NotFound).Send('Fatura não encontrada.');
  finally Service.Free; end;
end;

procedure SalvarFatura(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectFaturas; LBody: TJSONObject;
begin
  Service := TdmGILConnectFaturas.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) and Service.Inserir(LBody) then
      Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.Created)
    else
      Res.Status(THTTPStatus.BadRequest).Send('Erro ao gerar fatura.');
  finally Service.Free; end;
end;

procedure LiquidarFatura(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  Service: TdmGILConnectFaturas;
  LBody: TJSONObject;
  vForma: string;
begin
  Service := TdmGILConnectFaturas.Create(nil);
  try
    LBody := TJSONObject.ParseJSONValue(Req.Body) as TJSONObject;
    if Assigned(LBody) then
    begin
      vForma := LBody.GetValue<string>('formaPagamento', 'PIX');
      if Service.BaixarFatura(Req.Params['id'].ToInt64, vForma) then
        Res.Send<TJSONObject>(Service.qryAux.ToJSONObject()).Status(THTTPStatus.OK)
      else
        Res.Status(THTTPStatus.InternalServerError).Send('Não foi possível baixar a fatura.');
    end
    else
      Res.Status(THTTPStatus.BadRequest).Send('Corpo da requisição inválido.');
  finally Service.Free; end;
end;

procedure ExcluirFatura(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var Service: TdmGILConnectFaturas;
begin
  Service := TdmGILConnectFaturas.Create(nil);
  try
    if Service.Deletar(Req.Params['id'].ToInt64) then
      Res.Status(THTTPStatus.NoContent).Send('')
    else
      Res.Status(THTTPStatus.InternalServerError).Send('Erro ao excluir fatura.');
  finally Service.Free; end;
end;

procedure Registry;
begin
  THorse.Get('/faturas', ListarFaturas);
  THorse.Get('/faturas/:id', ObterFatura);
  THorse.Post('/faturas', SalvarFatura);
  THorse.Post('/faturas/:id/baixar', LiquidarFatura); // Rota especializada para liquidação
  THorse.Delete('/faturas/:id', ExcluirFatura);
end;

end.
