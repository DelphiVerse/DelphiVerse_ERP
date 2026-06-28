unit srvIntellisoft_ERP.controller.Clientes;

interface

uses
  Horse;

procedure Registry;

implementation

procedure DoGetClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin
  Res.Send('Rota de Clientes');
end;

procedure DoGetByIdClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  id: string;
begin
  id := Req.Params['id'];

end;

procedure DoPostClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
begin

end;

procedure DoPutClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  id: string;
begin
  id := Req.Params['id'];

end;

procedure DoDeleteClientes(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  id: string;
begin
  id := Req.Params['id'];

end;

procedure Registry;
begin
  THorse
    .Get('gil/v1/clientes', DoGetClientes)
    .Post('gil/v1/clientes', DoPostClientes)
    .Get('gil/v1/clientes/:id', DoGetByIdClientes)
    .Put('gil/v1/clientes/:id', DoPutClientes)
    .Delete('gil/v1/clientes/:id', DoDeleteClientes)
end;

end.