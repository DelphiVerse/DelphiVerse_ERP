program srvIntellisoft_GIL;

{$APPTYPE CONSOLE}

uses
  Horse,
  Horse.CORS,
  Horse.Compression,
  Horse.Jhonson,
  Horse.OctetStream,
  Horse.HandleException,
  Horse.Logger,
  Horse.BasicAuthentication,
  Horse.Documentation,
  Horse.Documentation.OpenApi.Interfaces,
  Horse.Documentation.OpenApi.Types,

  System.SysUtils,
  System.JSON,

  ServerGIL.providers.ProviderConnection in 'Providers\ServerGIL.providers.ProviderConnection.pas' {dmGILConnect: TDataModule},
  srvIntellisoft_GIL.controller.Clientes in 'Controllers\srvIntellisoft_GIL.controller.Clientes.pas',
  srvIntellisof_GIL.service.Clientes in 'Services\srvIntellisof_GIL.service.Clientes.pas' {dmGILConnectClientes: TDataModule},
  untLibrary in 'Common\untLibrary.pas',
  srvIntellisof_GIL.service.Planos in 'Services\srvIntellisof_GIL.service.Planos.pas' {dmGILConnectPlanos: TDataModule},
  srvIntellisof_GIL.service.Modulos in 'Services\srvIntellisof_GIL.service.Modulos.pas' {dmGILConnectModulos: TDataModule},
  srvIntellisof_GIL.service.Licencas in 'Services\srvIntellisof_GIL.service.Licencas.pas' {dmGILConnectLicencas: TDataModule},
  srvIntellisoft_GIL.controller.Planos in 'Controllers\srvIntellisoft_GIL.controller.Planos.pas',
  srvIntellisoft_GIL.controller.Modulos in 'Controllers\srvIntellisoft_GIL.controller.Modulos.pas',
  srvIntellisoft_GIL.controller.Licencas in 'Controllers\srvIntellisoft_GIL.controller.Licencas.pas',
  srvIntellisoft_GIL.controller.Faturas in 'Controllers\srvIntellisoft_GIL.controller.Faturas.pas',
  srvIntellisof_GIL.service.Faturas in 'Services\srvIntellisof_GIL.service.Faturas.pas' {dmGILConnectFaturas: TDataModule},
  srvIntellisoft_GIL.controller.CentroCustos in 'Controllers\srvIntellisoft_GIL.controller.CentroCustos.pas',
  srvIntellisof_GIL.service.CentroCustos in 'Services\srvIntellisof_GIL.service.CentroCustos.pas' {dmGILConnectCentroCustos: TDataModule},
  srvIntellisoft_GIL.controller.PlanoContas in 'Controllers\srvIntellisoft_GIL.controller.PlanoContas.pas',
  srvIntellisof_GIL.service.PlanoContas in 'Services\srvIntellisof_GIL.service.PlanoContas.pas' {dmGILConnectPlanoContas: TDataModule},
  srvIntellisoft_GIL.controller.LancamentosFinanceiros in 'Controllers\srvIntellisoft_GIL.controller.LancamentosFinanceiros.pas',
  srvIntellisof_GIL.service.LancamentosFinanceiros in 'Services\srvIntellisof_GIL.service.LancamentosFinanceiros.pas' {dmGILConnectLancFinanceiros: TDataModule},
  srvIntellisoft_GIL.controller.BaixasFinanceiras in 'Controllers\srvIntellisoft_GIL.controller.BaixasFinanceiras.pas',
  srvIntellisof_GIL.service.BaixasFinanceiras in 'Services\srvIntellisof_GIL.service.BaixasFinanceiras.pas' {dmGILConnectBaixasFinanceiras: TDataModule};

begin
  THorse
    .Use(CORS)
    .Use(Compression()) // Must come before Jhonson middleware
    .Use(Jhonson())
    .Use(OctetStream)
    .Use(HandleException)
    .Use(HorseDocumentation)
    .Use(THorseLoggerManager.HorseCallback())
    .Use(HorseBasicAuthentication(
      function(const AUsername, APassword: string): Boolean
        begin
            Result := AUsername.Equals('intellisoftGIL') and APassword.Equals('G1l2026');
              end));

  // 1. Descrevendo as informações gerais da API
  HorseDoc.Info
    .Title('API de Horse Gerenciador Interno de Licenças - GIL')
    .Version('0.1.0')
    .Description('API do GIL.')
    .Contact
      .Name('Intellisoft')
      .Email('desenvolvimento@intellisoftbr.com')
      .&End; // Volta para o objeto Info

  THorse.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    begin
      Res.Send('pong');
    end);

  srvIntellisoft_GIL.controller.Clientes.Registry;
  srvIntellisoft_GIL.controller.Planos.Registry;
  srvIntellisoft_GIL.controller.Modulos.Registry;
  srvIntellisoft_GIL.controller.Licencas.Registry;
  srvIntellisoft_GIL.controller.PlanoContas.Registry;
  srvIntellisoft_GIL.controller.CentroCustos.Registry;
  srvIntellisoft_GIL.controller.LancamentosFinanceiros.Registry;
  srvIntellisoft_GIL.controller.BaixasFinanceiras.Registry;

  THorse.Listen(9096,
    procedure
    begin
      Writeln('Servidor GIL executando na porta ' + IntToStr(THorse.Port));
      Readln;
    end);
end.