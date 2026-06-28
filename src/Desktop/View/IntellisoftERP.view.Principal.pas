unit IntellisoftERP.view.Principal;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Generics.Collections,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Objects,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.MultiView,
  FMX.StdCtrls,
  FMX.TreeView,

  IntellisoftERP.model.Licenca,
  IntellisoftERP.controller.Licenca,
  IntellisoftERP.bases.BaseCadastros,
  IntellisoftERP.view.Participantes,
  IntellisoftERP.view.Produtos;

type
  TFrameClass = class of TFrame;

type
  TfrmPrincipal = class(TForm)
    lytFundo: TLayout;
    rctFundo: TRectangle;
    lytTop: TLayout;
    rctTop: TRectangle;
    lblTop: TLabel;
    lytBtnMenuLateral: TLayout;
    btnMenuLateral: TSpeedButton;
    lytMenuLateral: TLayout;
    lytFrames: TLayout;
    pthBtnMenuLateral: TPath;
    tvMenuLateral: TTreeView;
    tviCadastros: TTreeViewItem;
    tviProdutos: TTreeViewItem;
    mtvMenuLateral: TMultiView;
    tviParticipantes: TTreeViewItem;
    tviFaturamento: TTreeViewItem;
    tviNFe: TTreeViewItem;
    tviNFSe: TTreeViewItem;
    tviSair: TTreeViewItem;
    tviConfiguracoes: TTreeViewItem;
    imgLogoFundo: TImage;
    procedure tviSairClick(Sender: TObject);
    procedure tviParticipantesClick(Sender: TObject);
    procedure tviProdutosClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FFrameAtivo: TFrame;
    FEstadoLicenca: TLicencaEstado;

    // Componentes criados dinamicamente para a UI de bloqueio
    rctBannerAviso: TRectangle;
    lblBannerAviso: TLabel;
    btnBannerRenovar: TButton;
    lytBloqueioTotal: TLayout;
    rctFundoBloqueio: TRectangle;
    rctPainelCentral: TRectangle;
    lblBloqueioTitulo: TLabel;
    imgQrCodePix: TImage;
    btnCopiarPix: TButton;
    btnChecarPagamento: TButton;

    procedure AnalisarRegrasDeLicenca(const AEstado: TLicencaEstado);
    procedure ExecutarChecagemInicial;
    procedure AbrirFrame(FrameClass: TFrameClass);
    procedure AbrirFormNoLayout(AFormClass: TFormClass);
    { Private declarations }
    // Métodos de construção da UI
    procedure CriarBannerAvisoUI;
    procedure CriarBloqueioTotalUI;
    procedure CarregarQrCodeBase64(const ABase64: string);

    // Eventos dos botões da K8 Fintech
    procedure OnCopiarPixClick(Sender: TObject);
    procedure OnChecarPagamentoClick(Sender: TObject);
    procedure OnRenovarClick(Sender: TObject);
  public
    { Public declarations }
    property EstadoLicenca: TLicencaEstado read FEstadoLicenca;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.fmx}

procedure TfrmPrincipal.AbrirFormNoLayout(AFormClass: TFormClass);
var
  NovoForm: TForm;
  I: Integer;
begin
  while lytForms.ControlsCount > 0 do
    lytForms.Controls[0].Parent := nil;

  NovoForm := AFormClass.Create(Self);

  // Procura o primeiro container visual do Form criado e injeta no Layout Principal
  for I := 0 to NovoForm.ChildrenCount - 1 do
  begin
    if NovoForm.Children[I] is TControl then
    begin
      TControl(NovoForm.Children[I]).Parent := lytForms;
      TControl(NovoForm.Children[I]).Align := TAlignLayout.Client;
      Break;
    end;
  end;

  // Se abrir uma tela enquanto estiver bloqueado por leitura, joga o painel K8 na frente
  if lytBloqueioTotal.Visible then
    lytBloqueioTotal.BringToFront;
end;

procedure TfrmPrincipal.AbrirFrame(FrameClass: TFrameClass);
begin
  // 1. Limpa o frame anterior, se existir
  if Assigned(FFrameAtivo) then
  begin
    FFrameAtivo.Parent := nil;
    FreeAndNil(FFrameAtivo);
  end;

  // 2. Instancia o novo frame
  FFrameAtivo := FrameClass.Create(Self);

  // 3. Configura o "Pai" e o alinhamento
  FFrameAtivo.Parent := lytFrames; //Layout que vai "receber" o Frame.
  FFrameAtivo.Align  := TAlignLayout.Client;

  // 4. (Opcional) Executa alguma rotina de inicialização do seu Frame Base
  // if FFrameAtivo is TFrameCadastroBase then
  //   TFrameCadastroBase(FFrameAtivo).ConfigurarTela;
end;

procedure TfrmPrincipal.AnalisarRegrasDeLicenca(const AEstado: TLicencaEstado);
begin
  FEstadoLicenca := AEstado;
  lblTituloTopo.Text := 'GIL - Gestão Interna de Licenças';

  // Reseta a visibilidade dos alertas
  rctBannerAviso.Visible := False;
  lytBloqueioTotal.Visible := False;
  rctMenuLateral.Enabled := True;

  // Cenário 1: Bloqueio Total (Modo Somente Leitura Ativo)
  if FEstadoLicenca.SomenteLeitura then
  begin
    rctMenuLateral.Enabled := False; // Trava o menu lateral do ERP
    lytBloqueioTotal.Visible := True; // Exibe a cortina e o QRCode Pix
    lytBloqueioTotal.BringToFront;

    // Desenha o QRCode recebido da K8 Fintech na tela
    if FEstadoLicenca.PixQrCodeBase64 <> '' then
      CarregarQrCodeBase64(FEstadoLicenca.PixQrCodeBase64);

    Exit;
  end;

  // Cenário 2: Período elegante de aviso (Entre 1 e 5 dias de Trial ou Vencimento)
  if (FEstadoLicenca.DiasRestantes <= 5) and (FEstadoLicenca.DiasRestantes > 0) then
  begin
    lblBannerAviso.Text := 'Atenção! Sua licença expira em ' + FEstadoLicenca.DiasRestantes.ToString +
                           ' dias. O sistema entrará em modo leitura após o vencimento.';
    rctBannerAviso.Visible := True;
    rctBannerAviso.BringToFront;
  end;
end;

procedure TfrmPrincipal.CarregarQrCodeBase64(const ABase64: string);
var
  LInput: TStringStream;
  LOutput: TBytesStream;
  LStringLimpa: string;
begin
  // Remove possíveis cabeçalhos que APIs costumam mandar ("data:image/png;base64,")
  if ABase64.Contains(',') then
    LStringLimpa := ABase64.Split([','])[1]
  else
    LStringLimpa := ABase64;

  LInput := TStringStream.Create(LStringLimpa);
  LOutput := TBytesStream.Create;
  try
    // Decodifica a string Base64 nativamente usando a unit NetEncoding do Delphi
    TNetEncoding.Base64.Decode(LInput, LOutput);
    LOutput.Position := 0;
    imgQrCodePix.Bitmap.LoadFromStream(LOutput);
  finally
    LInput.Free;
    LOutput.Free;
  end;
end;

procedure TfrmPrincipal.CriarBannerAvisoUI;
begin
  rctBannerAviso := TRectangle.Create(Self);
  rctBannerAviso.Parent := rctFundo;
  rctBannerAviso.Align := TAlignLayout.Top;
  rctBannerAviso.Height := 40;
  rctBannerAviso.Fill.Color := $FFFFEAEA; // Vermelho pastel suave
  rctBannerAviso.Stroke.Color := $FFFFB3B3;
  rctBannerAviso.Visible := False;

  lblBannerAviso := TLabel.Create(Self);
  lblBannerAviso.Parent := rctBannerAviso;
  lblBannerAviso.Align := TAlignLayout.Client;
  lblBannerAviso.Margins.Left := 20;
  lblBannerAviso.TextSettings.Font.Size := 13;
  lblBannerAviso.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblBannerAviso.TextSettings.FontColor := $FFCC0000; // Vermelho escuro
  lblBannerAviso.TextSettings.VertAlign := TTextAlign.Center;

  btnBannerRenovar := TButton.Create(Self);
  btnBannerRenovar.Parent := rctBannerAviso;
  btnBannerRenovar.Align := TAlignLayout.Right;
  btnBannerRenovar.Width := 140;
  btnBannerRenovar.Margins.Top := 5;
  btnBannerRenovar.Margins.Bottom := 5;
  btnBannerRenovar.Margins.Right := 15;
  btnBannerRenovar.Text := 'Pagar via PIX Agora';
  btnBannerRenovar.OnClick := OnRenovarClick;
end;

procedure TfrmPrincipal.CriarBloqueioTotalUI;
begin
  // Cortina que cobre as telas abertas no lytForms
  lytBloqueioTotal := TLayout.Create(Self);
  lytBloqueioTotal.Parent := lytForms;
  lytBloqueioTotal.Align := TAlignLayout.Client;
  lytBloqueioTotal.Visible := False;

  // Fundo semi-transparente fosco
  rctFundoBloqueio := TRectangle.Create(Self);
  rctFundoBloqueio.Parent := lytBloqueioTotal;
  rctFundoBloqueio.Align := TAlignLayout.Client;
  rctFundoBloqueio.Fill.Color := $D9333333; // Cinza escuro com opacidade
  rctFundoBloqueio.Stroke.Kind := TBrushKind.None;

  // Painel Central Branco com Cantos Arredondados
  rctPainelCentral := TRectangle.Create(Self);
  rctPainelCentral.Parent := lytBloqueioTotal;
  rctPainelCentral.Align := TAlignLayout.Center;
  rctPainelCentral.Width := 380;
  rctPainelCentral.Height := 460;
  rctPainelCentral.XRadius := 8;
  rctPainelCentral.YRadius := 8;
  rctPainelCentral.Fill.Color := claWhite;

  lblBloqueioTitulo := TLabel.Create(Self);
  lblBloqueioTitulo.Parent := rctPainelCentral;
  lblBloqueioTitulo.Align := TAlignLayout.Top;
  lblBloqueioTitulo.Height := 50;
  lblBloqueioTitulo.Text := 'LICENÇA EXPIRADA' + #13 + 'Efetue o pagamento PIX para liberar o sistema';
  lblBloqueioTitulo.TextSettings.Font.Size := 14;
  lblBloqueioTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  lblBloqueioTitulo.TextSettings.FontColor := $FF333333;
  lblBloqueioTitulo.TextSettings.HorzAlign := TTextAlign.Center;
  lblBloqueioTitulo.TextSettings.VertAlign := TTextAlign.Center;
  lblBloqueioTitulo.Margins.Top := 15;

  // Área do QRCode
  imgQrCodePix := TImage.Create(Self);
  imgQrCodePix.Parent := rctPainelCentral;
  imgQrCodePix.Align := TAlignLayout.Client;
  imgQrCodePix.Margins.Left := 40;
  imgQrCodePix.Margins.Right := 40;
  imgQrCodePix.Margins.Top := 10;
  imgQrCodePix.Margins.Bottom := 10;

  // Botão Copiar Linha Digitável
  btnCopiarPix := TButton.Create(Self);
  btnCopiarPix.Parent := rctPainelCentral;
  btnCopiarPix.Align := TAlignLayout.Bottom;
  btnCopiarPix.Height := 40;
  btnCopiarPix.Margins.Left := 30;
  btnCopiarPix.Margins.Right := 30;
  btnCopiarPix.Margins.Bottom := 10;
  btnCopiarPix.Text := 'Copiar PIX Copia e Cola';
  btnCopiarPix.OnClick := OnCopiarPixClick;

  // Botão Checar Atualização de Pagamento
  btnChecarPagamento := TButton.Create(Self);
  btnChecarPagamento.Parent := rctPainelCentral;
  btnChecarPagamento.Align := TAlignLayout.Bottom;
  btnChecarPagamento.Height := 40;
  btnChecarPagamento.Margins.Left := 30;
  btnChecarPagamento.Margins.Right := 30;
  btnChecarPagamento.Margins.Bottom := 20;
  btnChecarPagamento.Text := 'Já paguei, liberar sistema!';
  btnChecarPagamento.OnClick := OnChecarPagamentoClick;
end;

procedure TfrmPrincipal.ExecutarChecagemInicial;
begin
  lblTituloTopo.Text := 'Verificando licença do sistema...';

  // Consulta assíncrona baseada na nossa controller
  TLicencaController.ValidarLicencaAssincrono('00000000000000',
    procedure(const AEstado: TLicencaEstado)
    begin
      AnalisarRegrasDeLicenca(AEstado);
    end);
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  // Instancia as estruturas visuais ocultas na inicialização
  CriarBannerAvisoUI;
  CriarBloqueioTotalUI;

  // Dispara a checagem em segundo plano na API Horse
  ExecutarChecagemInicial;
end;

procedure TfrmPrincipal.OnChecarPagamentoClick(Sender: TObject);
begin
  // Força uma revalidação instantânea chamando a controller de volta à API Horse
  ExecutarChecagemInicial;
end;

procedure TfrmPrincipal.OnCopiarPixClick(Sender: TObject);
var
  LClipboard: IFMXClipboardService;
begin
  if FEstadoLicenca.PixCopiaCola <> '' then
  begin
    // Verifica se a plataforma atual suporta o serviço de Clipboard
    if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, IInterface(LClipboard)) then
    begin
      LClipboard.SetClipboard(FEstadoLicenca.PixCopiaCola);
      ShowMessage('Código PIX Copia e Cola copiado com sucesso!');
    end
    else
      ShowMessage('A área de transferência não é suportada neste sistema.');
  end;
end;

procedure TfrmPrincipal.OnRenovarClick(Sender: TObject);
begin
  // Caso o usuário clique em renovar pelo banner amigável antes do bloqueio,
  // nós simulamos a ativação visual forçada da janela do PIX para ele pagar antecipado
  lytBloqueioTotal.Visible := True;
  lytBloqueioTotal.BringToFront;
  if FEstadoLicenca.PixQrCodeBase64 <> '' then
    CarregarQrCodeBase64(FEstadoLicenca.PixQrCodeBase64);
end;

procedure TfrmPrincipal.tviParticipantesClick(Sender: TObject);
begin
  AbrirFormNoLayout(TfrmCadastroClientes);
//  AbrirFrame(TfrmCadastroParticipantes);
//  tvMenuLateral.CollapseAll;
//  mtvMenuLateral.HideMaster;
end;

procedure TfrmPrincipal.tviProdutosClick(Sender: TObject);
begin
  AbrirFrame(TfrmCadastroProdutos);
  tvMenuLateral.CollapseAll;
  mtvMenuLateral.HideMaster;
end;

procedure TfrmPrincipal.tviSairClick(Sender: TObject);
begin
  Close;
end;

end.
