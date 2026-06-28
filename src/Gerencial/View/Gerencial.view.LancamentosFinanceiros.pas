unit Gerencial.view.LancamentosFinanceiros;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.JSON,
  System.Generics.Collections,

  Gerencial.controller.Clientes,
  Gerencial.controller.LancamentosFinanceiros,
  Gerencial.controller.CentroCustos,
  Gerencial.controller.PlanoContas,
  Gerencial.bases.BaseCadastros,
  Gerencial.view.PesquisaClientes,
  Gerencial.model.LancamentosFinanceiros,
  Gerencial.view.BaixasFinanceiras,


  untLibrary,
  untConstantes,

  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.TabControl,
  FMX.Controls.Presentation,
  FMX.Objects,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Edit;

type
  TfrmLancFinanceiros = class(TfrmBaseCadastros)
    edtDescricao: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    cbbTipo: TComboBox;
    edtCodigoCliente: TEdit;
    lblCliente: TLabel;
    btnPesquisaCliente: TSpeedButton;
    edtNomeCliente: TEdit;
    cbbPlanoContas: TComboBox;
    cbbCentroCustos: TComboBox;
    lbl3: TLabel;
    lbl4: TLabel;
    edtValorOriginal: TEdit;
    Label1: TLabel;
    edtNumeroDocumento: TEdit;
    Label2: TLabel;
    lblStatus: TLabel;
    lytBtnBaixar: TLayout;
    rctBtnBaixar: TRectangle;
    lblBtnBaixar: TLabel;
    lblSaldo: TLabel;
    procedure lblBtnCancelarClick(Sender: TObject);
    procedure lblBtnGravarClick(Sender: TObject);
    procedure edtCodigoClienteKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure btnPesquisaClienteClick(Sender: TObject);
    procedure cbbTipoChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lstListagemDblClick(Sender: TObject);
    procedure edtCodigoClienteExit(Sender: TObject);
    procedure lblBtnBaixarClick(Sender: TObject);
  private
    FLancamentos: TLancamentosModel;
    FLancamentosController: TLancamentosController;
    procedure CarregarLista;
    procedure LimpaCampos;
    function BuscaNomeCliente(LClienteId: Integer): string;
    procedure CarregarComboCentroCustos;
    procedure CarregarComboPlanoContas;
    procedure GetValorComboBox(AComboBox: TComboBox);
    procedure GetStatus;
    procedure CalculaSaldo;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLancFinanceiros: TfrmLancFinanceiros;

implementation

{$R *.fmx}

procedure TfrmLancFinanceiros.btnPesquisaClienteClick(Sender: TObject);
var
  LFrmPesquisa: TfrmPesquisaClientes;
begin
  inherited;
  LFrmPesquisa := TfrmPesquisaClientes.Create(nil);
  try
    // Exibe a tela de pesquisa como modal
    if LFrmPesquisa.ShowModal = mrOk then
    begin
      // Se o usuário confirmou, resgata as propriedades públicas da tela de pesquisa
      FLancamentos.PessoaId := LFrmPesquisa.ClienteSelecionadoId;

      edtCodigoCliente.Text   := LFrmPesquisa.ClienteSelecionadoId.ToString;
      edtNomeCliente.Text := LFrmPesquisa.ClienteSelecionadoNome;
    end;
  finally
    LFrmPesquisa.Free;
  end;
end;

procedure TfrmLancFinanceiros.CarregarComboPlanoContas;
var
  LController: TPlanoContasController;
  LJsonArray: TJSONArray;
  LStrErro: string;
  I: Integer;
  LValue: TJSONValue;
  LId: Int64;
  LCodigo, LNome: string;
begin
  cbbPlanoContas.Items.Clear;
  cbbPlanoContas.Items.Add('--- Selecione o Plano de Conta ---');
  cbbPlanoContas.ListBox.ListItems[0].Tag := 0;

  LController := TPlanoContasController.Create;
  try
    LJsonArray := LController.ListarTodos(LStrErro);
    if Assigned(LJsonArray) then
    begin
      try
        for I := 0 to LJsonArray.Count - 1 do
        begin
          LValue := LJsonArray.Items[I];

          LId := 0;
          if LValue.FindValue('id') <> nil then
            LId := StrToInt64Def(LValue.FindValue('id').Value, 0);

          LCodigo := '';
          if LValue.FindValue('codigo_contabil') <> nil then
            LCodigo := LValue.FindValue('codigo_contabil').Value
          else if LValue.FindValue('codigoContabil') <> nil then
            LCodigo := LValue.FindValue('codigoContabil').Value;

          LNome := '';
          if LValue.FindValue('nome') <> nil then
            LNome := LValue.FindValue('nome').Value;

          if (LId > 0) and (LNome <> '') then
          begin
            // Formata a exibição elegante: "1.01.01 - Nome da Conta"
            if LCodigo <> '' then
              cbbPlanoContas.Items.Add(Format('%s - %s', [LCodigo, LNome]))
            else
              cbbPlanoContas.Items.Add(LNome);

            // Injeta o ID BigInt na Tag correspondente
            cbbPlanoContas.ListBox.ListItems[cbbPlanoContas.Items.Count - 1].Tag := LId;
          end;
        end;
      finally
        LJsonArray.Free;
      end;
    end
    else if LStrErro <> '' then
      Tlibrary.GravarLog('Erro ao carregar combo plano de contas: ' + LStrErro);
  finally
    LController.Free;
  end;
end;

procedure TfrmLancFinanceiros.CarregarComboCentroCustos;
var
  LController: TCentroCustosController;
  LJsonArray: TJSONArray;
  LStrErro: string;
  I: Integer;
  LValue: TJSONValue;
  LId: Int64;
  LNome: string;
//  LItem: TListBoxItem;
begin
  cbbCentroCustos.Items.Clear;

  // Como a DDL permite NULL, adicionamos uma opção padrão de "Nenhum"
  cbbCentroCustos.Items.Add('--- Nenhum (Sem Centro de Custo) ---');
  cbbCentroCustos.ListBox.ListItems[0].Tag := 0; // Define o ID 0 para indicar nulo

  LController := TCentroCustosController.Create;
  try
    LJsonArray := LController.ListarTodos(LStrErro);
    if Assigned(LJsonArray) then
    begin
      try
        for I := 0 to LJsonArray.Count - 1 do
        begin
          LValue := LJsonArray.Items[I];

          LId := 0;
          if LValue.FindValue('id') <> nil then
            LId := StrToInt64Def(LValue.FindValue('id').Value, 0);

          LNome := '';
          if LValue.FindValue('nome') <> nil then
            LNome := LValue.FindValue('nome').Value;

          if (LId > 0) and (LNome <> '') then
          begin
            cbbCentroCustos.Items.Add(LNome);
            // Armazena com segurança o ID Int64/BigInt na propriedade Tag do item FMX
            cbbCentroCustos.ListBox.ListItems[cbbCentroCustos.Items.Count - 1].Tag := LId;
          end;
        end;
      finally
        LJsonArray.Free;
      end;
    end
    else if LStrErro <> '' then
      Tlibrary.GravarLog('Erro ao carregar combo centro de custos: ' + LStrErro);
  finally
    LController.Free;
  end;
end;

function TfrmLancFinanceiros.BuscaNomeCliente(LClienteId: Integer): string;
var
  LStrErro: string;
  LControllerCliente: TClienteController;
begin
  LControllerCliente:= TClienteController.Create;
  try
    Result := LControllerCliente.GetNomePorId(LClienteId, LStrErro);
    if LStrErro <> '' then
    begin
      ShowMessage(LStrErro);
      Tlibrary.GravarLog(LStrErro);
    end;
  finally
    LControllerCliente.Free;
  end;
end;

procedure TfrmLancFinanceiros.CarregarLista;
var
  LStrErro: string;
  LJsonArray: TJSONArray;
  LItem: TListViewItem;
  I: Integer;
  LValue: TJSONValue;

  // Variáveis do banco e virtuais
  LId: Int64;
  LTipo, LDescricao, LNumDoc, LStatus: string;
  LPessoaNome, LPlanoContaNome: string;
  LValorOriginal: Double;
  LDataVencString: string;
  LDetailText: string;
begin
  LJsonArray := FLancamentosController.ListarTodos(LStrErro);

  if Assigned(LJsonArray) then
  begin
    try
      lstListagem.BeginUpdate;
      try
        lstListagem.Items.Clear;

        for I := 0 to LJsonArray.Count - 1 do
        begin
          LValue := LJsonArray.Items[I];
          LItem := lstListagem.Items.Add;

          // 1. Extração Segura de IDs (Int64)
          LId := 0;
          if LValue.FindValue('id') <> nil then LId := StrToInt64Def(LValue.FindValue('id').Value, 0);
          LItem.Tag := LId;

          // 2. Extração dos Textos e Joins Virtuais
          LTipo := ''; if LValue.FindValue('tipoLancamento') <> nil then LTipo := LValue.FindValue('tipoLancamento').Value else if LValue.FindValue('tipo_lancamento') <> nil then LTipo := LValue.FindValue('tipo_lancamento').Value;
          LDescricao := ''; if LValue.FindValue('descricao') <> nil then LDescricao := LValue.FindValue('descricao').Value;
          LNumDoc := ''; if LValue.FindValue('numeroDocumento') <> nil then LNumDoc := LValue.FindValue('numeroDocumento').Value else if LValue.FindValue('numero_documento') <> nil then LNumDoc := LValue.FindValue('numero_documento').Value;
          LStatus := ''; if LValue.FindValue('status') <> nil then LStatus := LValue.FindValue('status').Value;

          LPessoaNome := ''; if LValue.FindValue('pessoaNome') <> nil then LPessoaNome := LValue.FindValue('pessoaNome').Value else if LValue.FindValue('pessoa_nome') <> nil then LPessoaNome := LValue.FindValue('pessoa_nome').Value;
          LPlanoContaNome := ''; if LValue.FindValue('planoContaNome') <> nil then LPlanoContaNome := LValue.FindValue('planoContaNome').Value else if LValue.FindValue('plano_conta_name') <> nil then LPlanoContaNome := LValue.FindValue('plano_conta_name').Value;

          // 3. Extração Numérica com Proteção de Ponto/Vírgula Internacional
          LValorOriginal := 0.00;
          if LValue.FindValue('valorOriginal') <> nil then LValorOriginal := StrToFloatDef(LValue.FindValue('valorOriginal').Value, 0.00, TFormatSettings.Invariant)
          else if LValue.FindValue('valor_original') <> nil then LValorOriginal := StrToFloatDef(LValue.FindValue('valor_original').Value, 0.00, TFormatSettings.Invariant);

          // 4. Montagem do TÍTULO PRINCIPAL
          // Exibe o indicador visual de fluxo de caixa, o nome do Cliente/Fornecedor e o número do doc se houver
          if LTipo.ToUpper = 'CRÉDITO' then
            LItem.Text := '[CRE] ' + LPessoaNome
          else
            LItem.Text := '[DEB] ' + LPessoaNome;

          if LNumDoc <> '' then
            LItem.Text := LItem.Text + ' (Doc: ' + LNumDoc + ')';

          // 5. Montagem do SUBTÍTULO (Detail)
          // Exibe a Categoria (Plano de Contas) | Descrição | Valor | Vencimento
          LDetailText := LPlanoContaNome;
          if LDescricao <> '' then LDetailText := LDetailText + ' - ' + LDescricao;
          LDetailText := LDetailText + ' | ' + FormatCurr('R$ #,##0.00', LValorOriginal);

          // Captura e formata a Data de Vencimento
          LDataVencString := '';
          if LValue.FindValue('dataVencimento') <> nil then LDataVencString := LValue.FindValue('dataVencimento').Value
          else if LValue.FindValue('data_vencimento') <> nil then LDataVencString := LValue.FindValue('data_vencimento').Value;

          if LDataVencString.Length >= 10 then
            LDetailText := LDetailText + ' | Venc: ' + LDataVencString.Substring(8,2) + '/' + LDataVencString.Substring(5,2) + '/' + LDataVencString.Substring(0,4);

          // Tradução do Status do Título para exibição amigável
          // A=ABERTO, B=BAIXADO, P=PARCIAL, C=CANCELADO
          if LStatus.ToUpper = 'A' then LDetailText := LDetailText + ' | Em Aberto'
          else if LStatus.ToUpper = 'B' then LDetailText := LDetailText + ' | Pago/Baixado'
          else if LStatus.ToUpper = 'P' then LDetailText := LDetailText + ' | Baixa Parcial'
          else if LStatus.ToUpper = 'C' then LDetailText := LDetailText + ' | Cancelado';

          LItem.Detail := LDetailText;
        end;
      finally
        lstListagem.EndUpdate;
        lstListagem.Repaint;
      end;
    finally
      LJsonArray.Free;
    end;
  end
  else if LStrErro <> '' then
  begin
    ShowMessage('Erro ao carregar lançamentos financeiros: ' + LStrErro);
  end;
end;

procedure TfrmLancFinanceiros.cbbTipoChange(Sender: TObject);
begin
  inherited;
  if cbbTipo.Text = 'DÉBITO' then
    lblCliente.Text:= 'Fornecedor (F8)'
  else
    lblCliente.Text:= 'Cliente (F8)';
end;

procedure TfrmLancFinanceiros.edtCodigoClienteExit(Sender: TObject);
begin
  inherited;
  if edtCodigoCliente.Text <> '' then
    edtNomeCliente.Text:= BuscaNomeCliente(StrToInt(edtCodigoCliente.Text));
end;

procedure TfrmLancFinanceiros.edtCodigoClienteKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  inherited;
  if Key = vkF8 then
    btnPesquisaClienteClick(nil);
end;

procedure TfrmLancFinanceiros.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action:= TCloseAction.caFree;
end;

procedure TfrmLancFinanceiros.FormCreate(Sender: TObject);
begin
  inherited;
  CarregarComboPlanoContas;
  CarregarComboCentroCustos;
  FLancamentos := TLancamentosModel.Create;
  FLancamentosController := TLancamentosController.Create;
  LimpaCampos;
  CarregarLista;
  tbcCampos.ActiveTab := tbiCadastro;
  Tlibrary.AjustaPosicaoBotoes(rctBotoes);
  edtNomeCliente.SetFocus;
end;

procedure TfrmLancFinanceiros.FormDestroy(Sender: TObject);
begin
  inherited;
  FLancamentos.Free;
  FLancamentosController.Free;
end;

procedure TfrmLancFinanceiros.lblBtnBaixarClick(Sender: TObject);
begin
  inherited;
  if lblStatus.Text = '' then
  begin
    ShowMessage('Selecione um lançamento para baixar!');
    Exit;
  end;

  if lblStatus.Text = 'CANCELADO' then
  begin
    ShowMessage('Esse lançamento encontra-se cancelado!');
    Exit;
  end;
  Application.CreateForm(TfrmBaixasFinanceiras, frmBaixasFinanceiras);
  frmBaixasFinanceiras.FIdLancamento  := FLancamentos.Id;
  frmBaixasFinanceiras.FValorOriginal := FLancamentos.ValorOriginal;
  frmBaixasFinanceiras.FValorPago     := FLancamentos.ValorPago;
  frmBaixasFinanceiras.ShowModal;
  frmBaixasFinanceiras.Free;
  CarregarLista;
  LimpaCampos;
end;

procedure TfrmLancFinanceiros.CalculaSaldo;
begin
  lblSaldo.Text:= 'Saldo: ' + FormatFloat('R$ #,##0.00', FLancamentos.ValorOriginal - FLancamentos.ValorPago);
end;

procedure TfrmLancFinanceiros.lblBtnCancelarClick(Sender: TObject);
begin
  inherited;
  LimpaCampos;
end;

procedure TfrmLancFinanceiros.lblBtnGravarClick(Sender: TObject);
var
  lErro: string;
begin
  inherited;
  if edtCodigoCliente.Text.Trim = '' then
  begin
    Tlibrary.MensagemCampoVazio('Cliente');
    Exit;
  end;

  if cbbPlanoContas.ItemIndex <= 0 then
  begin
    Tlibrary.MensagemCampoVazio('Plano de Contas');
    cbbPlanoContas.SetFocus;
    Exit;
  end;

  if cbbCentroCustos.ItemIndex <= 0 then
  begin
    Tlibrary.MensagemCampoVazio('Centro de Custos');
    cbbCentroCustos.SetFocus;
    Exit;
  end;

  Tlibrary.TelaParaModel(FLancamentos, lytCamposCadastro, False);

  FLancamentos.PessoaId       := StrToInt(edtCodigoCliente.Text);
  FLancamentos.PlanoContaId   := cbbPlanoContas.ListBox.ListItems[cbbPlanoContas.ItemIndex].Tag;
  FLancamentos.CentroCustoId  := cbbCentroCustos.ListBox.ListItems[cbbCentroCustos.ItemIndex].Tag; // Se for 0, grava plano geral
  FLancamentos.TipoLancamento := cbbTipo.Text;
  FLancamentos.ValorOriginal  := StrToFloatDef(edtValorOriginal.Text.Replace('R$', '').Trim, 0.00);
  FLancamentos.DataEmissao    := Date;
  FLancamentos.DataVencimento := Date + 30;
  if edtNumeroDocumento.Text = '' then
    FLancamentos.NumeroDocumento:= '0';

  if not FLancamentosController.Salvar(FLancamentos, lErro) then
  begin
    ShowMessage(Format(_MENSAGEM_FALHA_GRAVACAO, [lErro]));
    Tlibrary.GravarLog(Format(_MENSAGEM_FALHA_GRAVACAO, [lErro]));
  end
  else
  begin
    ShowMessage(_MENSAGEM_SUCESSO_GRAVACAO);
    LimpaCampos;
    CarregarLista;
  end;
end;

procedure TfrmLancFinanceiros.GetValorComboBox(AComboBox: TComboBox);
begin
  AComboBox.ItemIndex := 0;
  for var I := 0 to AComboBox.Items.Count - 1 do
  begin
    if Copy(AComboBox.Name, 4, Length(AComboBox.Name)-1) = 'PlanoContas' then
    begin
      if AComboBox.ListBox.ListItems[I].Tag = FLancamentos.PlanoContaId then
      begin
        AComboBox.ItemIndex := I;
        Break;
      end;
    end;
    if Copy(AComboBox.Name, 4, Length(AComboBox.Name)-1) = 'CentroCustos' then
    begin
      if AComboBox.ListBox.ListItems[I].Tag = FLancamentos.CentroCustoId then
      begin
        AComboBox.ItemIndex := I;
        Break;
      end;
    end;
    if Copy(AComboBox.Name, 4, Length(AComboBox.Name)-1) = 'Tipo' then
    begin
      if AComboBox.ListBox.ListItems[I].Text = FLancamentos.TipoLancamento then
      begin
        AComboBox.ItemIndex := I;
        Break;
      end;
    end;
  end;
end;

procedure TfrmLancFinanceiros.LimpaCampos;
begin
  FLancamentos.Free;
  FLancamentos := TLancamentosModel.Create;
  Tlibrary.LimparTodosOsCampos(lytCamposCadastro);
  lblStatus.Text:= '';
  lblSaldo.Text := 'Saldo:';
  edtDescricao.SetFocus;
end;

procedure TfrmLancFinanceiros.GetStatus;
begin
  lblStatus.StyledSettings := lblStatus.StyledSettings - [TStyledSetting.FontColor];
  case FLancamentos.Status.ToUpper[1] of //A=ABERTO, B=BAIXADO, P=PARCIAL, C=CANCELADO
    'A':
    begin
      lblStatus.Text:= 'ABERTO';
      lblStatus.TextSettings.FontColor:= TAlphaColors.Red;
    end;
    'B':
    begin
      lblStatus.Text:= 'BAIXADO';
      lblStatus.TextSettings.FontColor:= TAlphaColors.Green;
    end;
    'P':
    begin
      lblStatus.Text:= 'PARCIAL';
      lblStatus.TextSettings.FontColor:= TAlphaColors.Red;
    end;
    'C':
    begin
      lblStatus.Text:= 'CANCELADO';
      lblStatus.TextSettings.FontColor:= TAlphaColors.Blue;
    end;
  end;
end;

procedure TfrmLancFinanceiros.lstListagemDblClick(Sender: TObject);
var
  LStrErro: string;
  LValorOriginal: Double;
begin
  inherited;
  FLancamentos  := FLancamentosController.CarregarPorId(lstListagem.Items[lstListagem.Selected.Index].Tag, LStrErro);
  Tlibrary.ModelParaTela(FLancamentos, lytCamposCadastro);
  LValorOriginal:= FLancamentos.ValorOriginal;
  GetValorComboBox(cbbPlanoContas);
  GetValorComboBox(cbbCentroCustos);
  GetValorComboBox(cbbTipo);
  GetStatus;
  edtValorOriginal.Text := FormatFloat('#,##0.00', LValorOriginal);
  edtCodigoCliente.Text := FLancamentos.PessoaId.ToString;
  edtCodigoClienteExit(nil);
  CalculaSaldo;
  tbcCampos.ActiveTab   := tbiCadastro;
  edtCodigoCliente.SetFocus;
end;

end.
