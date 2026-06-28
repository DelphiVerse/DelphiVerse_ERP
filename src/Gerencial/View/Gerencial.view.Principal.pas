unit Gerencial.view.Principal;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.NetEncoding,
  System.UIConsts,

  FMX.Platform,
  FMX.Surfaces,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Layouts,

  Gerencial.view.CadastroClientes,
  Gerencial.view.CadastroModulos,
  Gerencial.view.CadastroPlanos,
  Gerencial.view.CadastroLicencas,
  Gerencial.view.CadastroPlanoContas,
  Gerencial.view.CadastroCentroCustos,
  Gerencial.view.LancamentosFinanceiros;

type
  TFormClass = class of TForm;

type
  TfrmPrincipal = class(TForm)
    lytFundo: TLayout;
    rctFundo: TRectangle;
    lytTopo: TLayout;
    rctTopo: TRectangle;
    lblTituloTopo: TLabel;
    lytMenuLateral: TLayout;
    rctMenuLateral: TRectangle;
    lytBtnClientes: TLayout;
    rctBtnClientes: TRectangle;
    lblBtnClientes: TLabel;
    lytBtnLicencas: TLayout;
    rctBtnLicencas: TRectangle;
    lblBtnLicencas: TLabel;
    imgLogoTopo: TImage;
    imgLogoCentro: TImage;
    lytForms: TLayout;
    lytBtnModulos: TLayout;
    rctBtnModulos: TRectangle;
    lblBtnModulos: TLabel;
    lytBtnPlanos: TLayout;
    rctBtnPlanos: TRectangle;
    lblBtnPlanos: TLabel;
    lytBtnLanFinanceiro: TLayout;
    rctBtnLancFinanceiro: TRectangle;
    lblBtnLancFinanceiro: TLabel;
    lytBtnPlanoContas: TLayout;
    rctBtnPlanoContas: TRectangle;
    lblBtnPlanoContas: TLabel;
    lytBtnCentroCustos: TLayout;
    rctBtnCentroCuistos: TRectangle;
    lblBtnCentroCustos: TLabel;
    procedure lblBtnClientesClick(Sender: TObject);
    procedure lblBtnModulosClick(Sender: TObject);
    procedure lblBtnLicencasClick(Sender: TObject);
    procedure lblBtnPlanosClick(Sender: TObject);
    procedure lblBtnPlanoContasClick(Sender: TObject);
    procedure lblBtnCentroCustosClick(Sender: TObject);
    procedure lblBtnLancFinanceiroClick(Sender: TObject);
  private
    procedure AbrirFormNoLayout(AFormClass: TFormClass);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

procedure TfrmPrincipal.AbrirFormNoLayout(AFormClass: TFormClass);
var
  NovoForm: TForm;
  I: Integer;
  LControl: TControl; // Variável local para garantir a referência
begin
  // Limpa o layout principal removendo os controles anteriores
  while lytForms.ControlsCount > 0 do
    lytForms.Controls[0].Parent := nil;

  // Cria a instância do novo formulário
  NovoForm := AFormClass.Create(Self);

  // Procura o primeiro container visual do Form criado
  for I := 0 to NovoForm.ChildrenCount - 1 do
  begin
    if NovoForm.Children[I] is TControl then
    begin
      // 1. Captura a referência do controle na variável local
      LControl := TControl(NovoForm.Children[I]);

      // 2. Altera o Parent (aqui o NovoForm.Children vai mudar/esvaziar, mas nosso ponteiro está salvo)
      LControl.Parent := lytForms;

      // 3. Aplica o alinhamento usando a nossa variável local com total segurança
      LControl.Align := TAlignLayout.Client;

      // Como já achamos e injetamos o container principal, paramos o laço
      Break;
    end;
  end;
end;

procedure TfrmPrincipal.lblBtnCentroCustosClick(Sender: TObject);
begin
  AbrirFormNoLayout(TfrmCadastroCentroCustos)
end;

procedure TfrmPrincipal.lblBtnClientesClick(Sender: TObject);
begin
  AbrirFormNoLayout(TfrmCadastroClientes);
end;

procedure TfrmPrincipal.lblBtnLancFinanceiroClick(Sender: TObject);
begin
  AbrirFormNoLayout(TfrmLancFinanceiros);
end;

procedure TfrmPrincipal.lblBtnLicencasClick(Sender: TObject);
begin
  AbrirFormNoLayout(TfrmCadastroLicencas);
end;

procedure TfrmPrincipal.lblBtnModulosClick(Sender: TObject);
begin
  AbrirFormNoLayout(TfrmCadastroModulos);
end;

procedure TfrmPrincipal.lblBtnPlanoContasClick(Sender: TObject);
begin
  AbrirFormNoLayout(TfrmCadPlanoContas);
end;

procedure TfrmPrincipal.lblBtnPlanosClick(Sender: TObject);
begin
  AbrirFormNoLayout(TfrmCadastroPlanos);
end;

end.
