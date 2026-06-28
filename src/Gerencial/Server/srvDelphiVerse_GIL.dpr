program srvDelphiVerse_GIL;

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
  srvDelphiVerse_GIL.controller.Clientes in 'Controllers\srvDelphiVerse_GIL.controller.Clientes.pas',
  srvDelphiVerse_GIL.service.Clientes in 'Services\srvDelphiVerse_GIL.service.Clientes.pas' {dmGILConnectClientes: TDataModule},
  untLibrary in 'Common\untLibrary.pas',
  srvDelphiVerse_GIL.service.Planos in 'Services\srvDelphiVerse_GIL.service.Planos.pas' {dmGILConnectPlanos: TDataModule},
  srvDelphiVerse_GIL.service.Modulos in 'Services\srvDelphiVerse_GIL.service.Modulos.pas' {dmGILConnectModulos: TDataModule},
  srvDelphiVerse_GIL.service.Licencas in 'Services\srvDelphiVerse_GIL.service.Licencas.pas' {dmGILConnectLicencas: TDataModule},
  srvDelphiVerse_GIL.controller.Planos in 'Controllers\srvDelphiVerse_GIL.controller.Planos.pas',
  srvDelphiVerse_GIL.controller.Modulos in 'Controllers\srvDelphiVerse_GIL.controller.Modulos.pas',
  srvDelphiVerse_GIL.controller.Licencas in 'Controllers\srvDelphiVerse_GIL.controller.Licencas.pas',
  srvDelphiVerse_GIL.controller.Faturas in 'Controllers\srvDelphiVerse_GIL.controller.Faturas.pas',
  srvDelphiVerse_GIL.service.Faturas in 'Services\srvDelphiVerse_GIL.service.Faturas.pas' {dmGILConnectFaturas: TDataModule},
  srvDelphiVerse_GIL.controller.CentroCustos in 'Controllers\srvDelphiVerse_GIL.controller.CentroCustos.pas',
  srvDelphiVerse_GIL.service.CentroCustos in 'Services\srvDelphiVerse_GIL.service.CentroCustos.pas' {dmGILConnectCentroCustos: TDataModule},
  srvDelphiVerse_GIL.controller.PlanoContas in 'Controllers\srvDelphiVerse_GIL.controller.PlanoContas.pas',
  srvDelphiVerse_GIL.service.PlanoContas in 'Services\srvDelphiVerse_GIL.service.PlanoContas.pas' {dmGILConnectPlanoContas: TDataModule},
  srvDelphiVerse_GIL.controller.LancamentosFinanceiros in 'Controllers\srvDelphiVerse_GIL.controller.LancamentosFinanceiros.pas',
  srvDelphiVerse_GIL.service.LancamentosFinanceiros in 'Services\srvDelphiVerse_GIL.service.LancamentosFinanceiros.pas' {dmGILConnectLancFinanceiros: TDataModule},
  srvDelphiVerse_GIL.controller.BaixasFinanceiras in 'Controllers\srvDelphiVerse_GIL.controller.BaixasFinanceiras.pas',
  srvDelphiVerse_GIL.service.BaixasFinanceiras in 'Services\srvDelphiVerse_GIL.service.BaixasFinanceiras.pas' {dmGILConnectBaixasFinanceiras: TDataModule};

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
            Result := AUsername.Equals('DelphiVerse') and APassword.Equals('Delphi2026');
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

  srvDelphiVerse_GIL.controller.Clientes.Registry;
  srvDelphiVerse_GIL.controller.Planos.Registry;
  srvDelphiVerse_GIL.controller.Modulos.Registry;
  srvDelphiVerse_GIL.controller.Licencas.Registry;
  srvDelphiVerse_GIL.controller.PlanoContas.Registry;
  srvDelphiVerse_GIL.controller.CentroCustos.Registry;
  srvDelphiVerse_GIL.controller.LancamentosFinanceiros.Registry;
  srvDelphiVerse_GIL.controller.BaixasFinanceiras.Registry;

  THorse.Listen(9096,
    procedure
    begin
      Writeln('Servidor GIL executando na porta ' + IntToStr(THorse.Port));
      Readln;
    end);
end.