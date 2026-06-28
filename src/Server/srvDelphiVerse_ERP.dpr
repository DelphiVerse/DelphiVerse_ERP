program srvDelphiVerse_ERP;

{$APPTYPE CONSOLE}

{$R 'scripts.res' '..\DB\scripts.rc'}

uses
  Horse,
  Horse.Compression,
  Horse.Jhonson,
  Horse.OctetStream,
  Horse.HandleException,
  Horse.Logger,
  Horse.BasicAuthentication,
  System.SysUtils,
  srvIntellisoft_ERP.controller.Clientes in 'Controllers\srvIntellisoft_ERP.controller.Clientes.pas',
  Server.providers.ProviderConnection in 'Providers\Server.providers.ProviderConnection.pas' {dmSrvConnect: TDataModule},
  srvIntellisof_ERP.service.Clientes in 'Services\srvIntellisof_ERP.service.Clientes.pas' {dmSrvConnect1: TDataModule};

begin
  THorse
    .Use(Compression()) // Must come before Jhonson middleware
    .Use(Jhonson())
    .Use(OctetStream)
    .Use(HandleException)
    .Use(THorseLoggerManager.HorseCallback())
    .Use(HorseBasicAuthentication(
      function(const AUsername, APassword: string): Boolean
        begin
            Result := AUsername.Equals('intellisoft') and APassword.Equals('srverp');
              end));

  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  srvIntellisoft_ERP.controller.Clientes.Registry;
  THorse.Listen(9097,
    procedure
    begin
      Writeln('Servidor Intellisoft ERP executando na porta ' + IntToStr(THorse.Port));
      Readln;
    end);
end.