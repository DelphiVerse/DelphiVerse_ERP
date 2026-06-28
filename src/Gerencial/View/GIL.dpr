program GIL;

uses
  System.StartUpCopy,
  FMX.Forms,
  Gerencial.view.Principal in 'Gerencial.view.Principal.pas' {frmPrincipal},
  Gerencial.bases.BaseCadastros in '..\Bases\Gerencial.bases.BaseCadastros.pas' {frmBaseCadastros},
  Gerencial.view.CadastroClientes in 'Gerencial.view.CadastroClientes.pas' {frmCadastroClientes},
  Gerencial.utils.Validacoes in '..\..\Comum\Utils\Gerencial.utils.Validacoes.pas',
  Gerencial.model.Clientes in '..\Model\Gerencial.model.Clientes.pas',
  Gerencial.controller.Clientes in '..\Controller\Gerencial.controller.Clientes.pas',
  untDmConnect in '..\..\Comum\untDmConnect.pas' {dmConnect: TDataModule},
  untLibrary in '..\Common\untLibrary.pas',
  untConstantes in '..\Common\untConstantes.pas',
  Gerencial.controller.LicencaStatus in '..\Controller\Gerencial.controller.LicencaStatus.pas',
  Gerencial.model.LicencaStatus in '..\Model\Gerencial.model.LicencaStatus.pas',
  Gerencial.view.CadastroModulos in 'Gerencial.view.CadastroModulos.pas' {frmCadastroModulos},
  Gerencial.model.Modulos in '..\Model\Gerencial.model.Modulos.pas',
  Gerencial.controller.Modulos in '..\Controller\Gerencial.controller.Modulos.pas',
  Gerencial.view.CadastroLicencas in 'Gerencial.view.CadastroLicencas.pas' {frmCadastroLicencas},
  Gerencial.model.Planos in '..\Model\Gerencial.model.Planos.pas',
  Gerencial.controller.Planos in '..\Controller\Gerencial.controller.Planos.pas',
  Gerencial.view.CadastroPlanos in 'Gerencial.view.CadastroPlanos.pas' {frmCadastroPlanos},
  Gerencial.model.Licenca in '..\Model\Gerencial.model.Licenca.pas',
  Gerencial.controller.Licenca in '..\Controller\Gerencial.controller.Licenca.pas',
  Gerencial.view.PesquisaClientes in 'Gerencial.view.PesquisaClientes.pas' {frmPesquisaClientes},
  Gerencial.view.LancamentosFinanceiros in 'Gerencial.view.LancamentosFinanceiros.pas' {frmLancFinanceiros},
  Gerencial.model.PlanoContas in '..\Model\Gerencial.model.PlanoContas.pas',
  Gerencial.controller.PlanoContas in '..\Controller\Gerencial.controller.PlanoContas.pas',
  Gerencial.view.CadastroPlanoContas in 'Gerencial.view.CadastroPlanoContas.pas' {frmCadPlanoContas},
  Gerencial.controller.CentroCustos in '..\Controller\Gerencial.controller.CentroCustos.pas',
  Gerencial.model.CentroCustos in '..\Model\Gerencial.model.CentroCustos.pas',
  Gerencial.view.CadastroCentroCustos in 'Gerencial.view.CadastroCentroCustos.pas' {frmCadastroCentroCustos},
  Gerencial.model.LancamentosFinanceiros in '..\Model\Gerencial.model.LancamentosFinanceiros.pas',
  Gerencial.controller.LancamentosFinanceiros in '..\Controller\Gerencial.controller.LancamentosFinanceiros.pas',
  Gerencial.model.BaixasFinanceiras in '..\Model\Gerencial.model.BaixasFinanceiras.pas',
  Gerencial.controller.BaixasFinanceiras in '..\Controller\Gerencial.controller.BaixasFinanceiras.pas',
  Gerencial.view.BaixasFinanceiras in 'Gerencial.view.BaixasFinanceiras.pas' {frmBaixasFinanceiras};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
