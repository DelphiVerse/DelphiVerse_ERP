program DelphiVerseERP;

uses
  System.StartUpCopy,
  FMX.Forms,
  DelphiVerseERP.view.Principal in 'View\DelphiVerseERP.view.Principal.pas' {frmPrincipal},
  IntellisoftERP.bases.BaseCadastros in 'Bases\IntellisoftERP.bases.BaseCadastros.pas' {frmBaseCadastro: TFrame},
  IntellisoftERP.view.Participantes in 'View\IntellisoftERP.view.Participantes.pas' {frmCadastroParticipantes: TFrame},
  IntellisoftERP.view.Produtos in 'View\IntellisoftERP.view.Produtos.pas' {frmCadastroProdutos: TFrame},
  IntellisoftERP.controller.Licenca in 'Controller\IntellisoftERP.controller.Licenca.pas',
  IntellisoftERP.model.Licenca in 'Model\IntellisoftERP.model.Licenca.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.Run;
end.
