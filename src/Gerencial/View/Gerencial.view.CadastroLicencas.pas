unit Gerencial.view.CadastroLicencas;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.JSON,

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
  FMX.Edit,

  Gerencial.bases.BaseCadastros,
  untLibrary,
  untConstantes,
  Gerencial.model.Licenca,
  Gerencial.controller.Licenca,
  Gerencial.controller.Modulos,
  Gerencial.model.Planos,
  Gerencial.controller.Planos,
  Gerencial.view.PesquisaClientes,
  Gerencial.controller.Clientes;

type
  TfrmCadastroLicencas = class(TfrmBaseCadastros)
    edtNomeCliente: TEdit;
    lbl1: TLabel;
    cbbPlanos: TComboBox;
    cbbModulos: TComboBox;
    edtValorCobrado: TEdit;
    Label1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    edtCodCliente: TEdit;
    btnPesquisaClientes: TSpeedButton;
    swtStatus: TSwitch;
    lbl4: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbbPlanosChange(Sender: TObject);
    procedure cbbModulosChange(Sender: TObject);
    procedure lstListagemDblClick(Sender: TObject);
    procedure lblBtnCancelarClick(Sender: TObject);
    procedure btnPesquisaClientesClick(Sender: TObject);
    procedure lblBtnGravarClick(Sender: TObject);
    procedure edtCodClienteKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure edtCodClienteExit(Sender: TObject);
    procedure tbcCamposChange(Sender: TObject);
  private
    FLicencas: TLicencaModel;
    FLicencasController: TLicencaController;
    fValorPlanoBase: Double; // Armazena o preço do plano ativo
    fValorModuloBase: Double; // Armazena o preço do módulo ativo
    procedure CarregarComboPlanos;
    procedure CarregarComboModulos;
    procedure RecalcularTotalLicenca;
    procedure CarregarLista;
    procedure LimpaCampos;
    function BuscaNomeCliente(LClienteId: Integer): string;
    function BuscaNomeModulo(LModuloId: Integer): string;
    function BuscaNomePlano(LPlanoId: Integer): string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCadastroLicencas: TfrmCadastroLicencas;

implementation

{$R *.fmx}

procedure TfrmCadastroLicencas.btnPesquisaClientesClick(Sender: TObject);
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
      FLicencas.ClienteId := LFrmPesquisa.ClienteSelecionadoId;

      // Alimenta os Edits visuais da tela de Licença
      edtCodCliente.Text   := LFrmPesquisa.ClienteSelecionadoId.ToString;
      edtNomeCliente.Text := LFrmPesquisa.ClienteSelecionadoNome;
    end;
  finally
    LFrmPesquisa.Free;
  end;
end;

procedure TfrmCadastroLicencas.CarregarComboModulos;
var
  LControllerModulo: TModuloController;
  LJsonArray: TJSONArray;
  LStrErro: string;
  I: Integer;
  LValue: TJSONValue;
  LId: Integer;
  LNome: string;
  LValor: Double;
begin
  cbbModulos.Items.Clear;
  cbbModulos.Items.Add('--- Nenhum ---');
  cbbModulos.ListBox.ListItems[0].Tag := 0; // Tag 0 indica sem módulo adicional
  cbbModulos.ListBox.ListItems[0].TagFloat := 0.00;

  LControllerModulo := TModuloController.Create;
  try
    LJsonArray := LControllerModulo.ListarTodos(LStrErro);
    if Assigned(LJsonArray) then
    begin
      try
        for I := 0 to LJsonArray.Count - 1 do
        begin
          LValue := LJsonArray.Items[I];

          LId    := 0;
          LNome  := '';
          LValor := 0.00;

          // Captura Segura do ID
          if not LValue.TryGetValue<Integer>('id', LId) then
            LValue.TryGetValue<Integer>('ID', LId);

          // Captura Segura do Nome
          if not LValue.TryGetValue<string>('nome', LNome) then
            LValue.TryGetValue<string>('NOME', LNome);

          LValor := StrToFloatDef(LValue.FindValue('valorAdicional').Value, 0.00, TFormatSettings.Invariant);

          // Se validou o ID e o Nome, insere no Combo com sucesso
          if (LId > 0) and (LNome <> '') then
          begin
            cbbModulos.Items.Add(LNome + ' (+ ' + FormatCurr('R$ #,##0.00', LValor) + ')');
            cbbModulos.ListBox.ListItems[cbbModulos.Items.Count - 1].Tag := LId;
            cbbModulos.ListBox.ListItems[cbbModulos.Items.Count - 1].TagFloat := LValor;
          end;
        end;
      finally
        LJsonArray.Free;
      end;
    end;
  finally
    LControllerModulo.Free;
  end;
end;

procedure TfrmCadastroLicencas.CarregarComboPlanos;
var
  LControllerPlanos: TPlanoController;
  LJsonArray: TJSONArray;
  LStrErro: string;
  I: Integer;
  LValue: TJSONValue;
  LId: Integer;
  LNome: string;
  LValor: Double;
begin
  cbbPlanos.Items.Clear;
  cbbPlanos.Items.Add('--- Nenhum ---');
  cbbPlanos.ListBox.ListItems[0].Tag := 0; // Tag 0 indica sem módulo adicional
  cbbPlanos.ListBox.ListItems[0].TagFloat := 0.00;

  LControllerPlanos := TPlanoController.Create;
  try
    LJsonArray := LControllerPlanos.ListarTodos(LStrErro);
    if Assigned(LJsonArray) then
    begin
      try
        for I := 0 to LJsonArray.Count - 1 do
        begin
          LValue := LJsonArray.Items[I];

          // Captura os valores individualmente para não derrubar o bloco todo
          LId   := 0;
          LNome := '';

          // Busca o ID (testa minúsculo e maiúsculo)
          if not LValue.TryGetValue<Integer>('id', LId) then
            LValue.TryGetValue<Integer>('ID', LId);

          // Busca o Nome
          if not LValue.TryGetValue<string>('nome', LNome) then
            LValue.TryGetValue<string>('NOME', LNome);

          // Se pelo menos o ID e o Nome forem válidos, nós adicionamos ao Combo!
          if (LId > 0) and (LNome <> '') then
          begin
            cbbPlanos.Items.Add(LNome);
            cbbPlanos.ListBox.ListItems[cbbPlanos.Items.Count - 1].Tag := LId;
          end;
        end;
      finally
        LJsonArray.Free;
      end;
    end;
  finally
    LControllerPlanos.Free;
  end;
end;

procedure TfrmCadastroLicencas.CarregarLista;
var
  LStrErro,
  LClienteNome,
  LPlanoNome,
  LModuloNome,
  LStatus,
  LDataVencString,
  LDetailText: string;

  I,
  LId,
  LClienteId,
  LModuloId,
  LPlanoId: Integer;

  LJsonArray: TJSONArray;
  LItem: TListViewItem;
  LValue: TJSONValue;
  LValorCobrado: Double;
  LDataVenc: TDateTime;
begin
  // Busca todas as licenças usando a Controller
  LJsonArray := FLicencasController.ListarTodas(LStrErro);

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

          // 1. Extração Resiliente de IDs e Textos (Trata chaves em camelCase e minúsculas)
          if not LValue.TryGetValue<Integer>('id', LId) then
            LValue.TryGetValue<Integer>('ID', LId);
          LItem.Tag := LId;

          LValue.TryGetValue<Integer>('clienteId', LClienteId);
          LValue.TryGetValue<Integer>('planoId', LPlanoId);
          LValue.TryGetValue<Integer>('moduloId', LModuloId);
          LValue.TryGetValue<Double>('valorTotal', LValorCobrado);
          LValue.TryGetValue<string>('status', LStatus);
          
          LClienteNome:= BuscaNomeCliente(LClienteId);
          LModuloNome:= BuscaNomeModulo(LModuloId);
          LPlanoNome:= BuscaNomePlano(LPlanoId);


          if LClienteNome <> '' then
            LItem.Text := LClienteNome
          else
            LItem.Text := 'Cliente Não Identificado';

          if (LPlanoNome = '') and (LModuloNome = '') then
            LDetailText := ' (Sem Plano ou Módulo Cadastrado.)'
          else
            LDetailText := Format('Plano: %s + Módulo: %s', [LPlanoNome, LModuloNome]);

          // Adiciona o valor financeiro cobrado na licença ao texto de detalhe
          LDetailText := LDetailText + ' | ' + FormatCurr('R$ #,##0.00', LValorCobrado);

          // 4. Tratamento e Formatação da Data de Vencimento
          if LValue.TryGetValue<string>('dataVencimento', LDataVencString) or
             LValue.TryGetValue<string>('data_vencimento', LDataVencString) then
          begin
            // Converte a string ISO vinda da API (ex: 2026-07-15) para TDateTime se necessário
            // ou lê diretamente dependendo de como o serialize entrega.
            if TryStrToDate(LDataVencString, LDataVenc) then
              LDetailText := LDetailText + ' | Venc: ' + FormatDateTime('dd/mm/yyyy', LDataVenc)
            else if LDataVencString.Length >= 10 then
              // Fallback rápido se vier no formato YYYY-MM-DD puro da API
              LDetailText := LDetailText + ' | Venc: ' +
                LDataVencString.Substring(8,2) + '/' + LDataVencString.Substring(5,2) + '/' + LDataVencString.Substring(0,4);
          end;

          // Aplica o texto formatado no Detail do componente visual
          LItem.Detail := LDetailText;

          // 5. UX de Status (Diferenciação visual no TListView)
          // Se o seu TListView estiver em DynamicAppearance, você pode mapear um objeto de texto ou imagem.
          // Como padrão de segurança text-only, concatenamos um indicador visual (Emoji Badge) no início do texto:
          if LStatus.ToUpper = 'A' then
            LItem.Text := 'Ativo - ' + LItem.Text
          else
            LItem.Text := 'Inativo - ' + LItem.Text;

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
    ShowMessage('Erro ao carregar o histórico de licenças: ' + LStrErro);
  end;
end;

procedure TfrmCadastroLicencas.cbbModulosChange(Sender: TObject);
begin
  inherited;
  fValorModuloBase := 0.00;
  if cbbModulos.ItemIndex <= 0 then
  begin
    FLicencas.ModuloId := 0; // Grava 0 no banco se escolher plano geral
    RecalcularTotalLicenca;
    Exit;
  end;

  // Resgata o ID e o Valor Adicional salvos nas propriedades Tags do item do combo
  FLicencas.ModuloId := cbbModulos.ListBox.ListItems[cbbModulos.ItemIndex].Tag;
  fValorModuloBase   := cbbModulos.ListBox.ListItems[cbbModulos.ItemIndex].TagFloat;

  RecalcularTotalLicenca;
end;

procedure TfrmCadastroLicencas.cbbPlanosChange(Sender: TObject);
var
  LControllerPlano: TPlanoController;
  LPlanoModel: TPlanoModel;
  LIdPlano: Integer;
  LStrErro: string;
begin
  inherited;
  fValorPlanoBase := 0.00;
  if cbbPlanos.ItemIndex <= 0 then
  begin
    FLicencas.PlanoId := 0;
    RecalcularTotalLicenca;
    Exit;
  end;

  LIdPlano := cbbPlanos.ListBox.ListItems[cbbPlanos.ItemIndex].Tag;
  FLicencas.PlanoId := LIdPlano;

  LControllerPlano := TPlanoController.Create;
  try
    LPlanoModel := LControllerPlano.CarregarPorId(LIdPlano, LStrErro);
    if Assigned(LPlanoModel) then
    begin
      try
        fValorPlanoBase := LPlanoModel.ValorBase;
      finally
        LPlanoModel.Free;
      end;
    end;
  finally
    LControllerPlano.Free;
  end;

  RecalcularTotalLicenca;
end;

procedure TfrmCadastroLicencas.edtCodClienteExit(Sender: TObject);
begin
  inherited;
  if edtCodCliente.Text <> '' then
  begin
    edtNomeCliente.Text:= BuscaNomeCliente(StrToInt(edtCodCliente.Text));
  end
  else
    edtNomeCliente.Text:= '';
end;

procedure TfrmCadastroLicencas.edtCodClienteKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  inherited;
  if Key = vkF8 then
    btnPesquisaClientesClick(nil);

  if (Key = vkReturn) and (edtCodCliente.Text <> '') then
  begin
    edtNomeCliente.Text:= BuscaNomeCliente(StrToInt(edtCodCliente.Text));
  end
  else if edtCodCliente.Text = '' then
       edtNomeCliente.Text:= '';
end;

procedure TfrmCadastroLicencas.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action:= TCloseAction.caFree;
end;

procedure TfrmCadastroLicencas.FormCreate(Sender: TObject);
begin
  inherited;
  CarregarComboPlanos;
  CarregarComboModulos;
  FLicencas := TLicencaModel.Create;
  FLicencasController := TLicencaController.Create;
  LimpaCampos;
  CarregarLista;
  tbcCampos.ActiveTab := tbiCadastro;
  Tlibrary.AjustaPosicaoBotoes(rctBotoes);
  edtNomeCliente.SetFocus;
end;

procedure TfrmCadastroLicencas.FormDestroy(Sender: TObject);
begin
  inherited;
  FLicencas.Free;
  FLicencasController.Free;
end;

procedure TfrmCadastroLicencas.lblBtnCancelarClick(Sender: TObject);
begin
  inherited;
  LimpaCampos;
end;

procedure TfrmCadastroLicencas.lblBtnGravarClick(Sender: TObject);
var
  lErro: string;
begin
  inherited;
  // 1. VALIDAÇÕES DE INTERFACE (UX DE SEGURANÇA)
  if edtCodCliente.Text.Trim = '' then
  begin
    Tlibrary.MensagemCampoVazio('Cliente (Use a lupa de pesquisa)');
    Exit;
  end;

  if cbbPlanos.ItemIndex <= 0 then
  begin
    Tlibrary.MensagemCampoVazio('Plano Base');
    cbbPlanos.SetFocus;
    Exit;
  end;

  // 2. SINCRONIZAÇÃO DOS DADOS DA TELA PARA A MODEL
  // O seu método genérico mapeia o que for comum por RTTI (como Status, ChaveAtivacao, etc)
  Tlibrary.TelaParaModel(FLicencas, lytCamposCadastro);

  // 3. CAPTURA DOS VÍNCULOS E CAMPOS MANUAIS
  // Os IDs salvos nas tags dos ComboBoxes e as Datas dos TDateEdit
  FLicencas.ClienteId      := StrToInt(edtCodCliente.Text);
  FLicencas.PlanoId        := cbbPlanos.ListBox.ListItems[cbbPlanos.ItemIndex].Tag;
  FLicencas.ModuloId       := cbbModulos.ListBox.ListItems[cbbModulos.ItemIndex].Tag; // Se for 0, grava plano geral

  // Captura o valor final (Plano + Módulo) limpando a formatação de moeda para Double
  FLicencas.ValorTotal   := StrToFloatDef(edtValorCobrado.Text.Replace('R$', '').Trim, 0.00);

  // Tratamento dos componentes de data do FMX (TDateEdit)
  FLicencas.DataInicio     := Date;
  FLicencas.DataVencimento := Date + 30;

  // Tratamento manual do Switch de Status para String ('ATIVO'/'INATIVO')
  if swtStatus.IsChecked then
    FLicencas.Status := 'A'
  else
    FLicencas.Status := 'I';

  // 4. ENVIO PARA O BACK-END HORSE VIA CONTROLLER
  if not FLicencasController.Salvar(FLicencas, lErro) then
  begin
    // Exibe o erro retornado pela API Horse e grava no Log local do ERP
    ShowMessage(Format(_MENSAGEM_FALHA_GRAVACAO, [lErro]));
    Tlibrary.GravarLog(Format(_MENSAGEM_FALHA_GRAVACAO, [lErro]));
  end
  else
  begin
    // Sucesso total! Mensagem amigável, limpa o formulário e atualiza o histórico
    ShowMessage(_MENSAGEM_SUCESSO_GRAVACAO);
    LimpaCampos;
    CarregarLista; // O método que fizemos na etapa anterior
  end;
end;

procedure TfrmCadastroLicencas.LimpaCampos;
begin
  FLicencas.Free;
  FLicencas := TLicencaModel.Create;
  Tlibrary.LimparTodosOsCampos(lytCamposCadastro);
  // Ajustes manuais específicos qude não seguem a regra geral
  //  lblID.Text:= 'ID:';
  swtStatus.IsChecked := True;
  cbbPlanos.ItemIndex := 0;
  cbbModulos.ItemIndex:= 0;
  edtCodCliente.SetFocus;
end;

function TfrmCadastroLicencas.BuscaNomeCliente(LClienteId: Integer):string;
var
  LStrErro: string;
  LControllerCliente: TClienteController;
begin
  try
    LControllerCliente:= TClienteController.Create;
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

function TfrmCadastroLicencas.BuscaNomeModulo(LModuloId: Integer): string;
var
  LStrErro: string;
  LControllerModulo: TModuloController;
begin
  try
    LControllerModulo:= TModuloController.Create;
    Result:= LControllerModulo.GetNomePorId(LModuloId, LStrErro);
    if (LStrErro <> '') and (LStrErro <> 'Erro ao buscar módulo: 404') then
    begin
      ShowMessage(LStrErro);
      Tlibrary.GravarLog(LStrErro);
    end;
  finally
    LControllerModulo.Free;
  end;  
end;

function TfrmCadastroLicencas.BuscaNomePlano(LPlanoId: Integer): string;
var
  LStrErro: string;
  LControllerPlano: TPlanoController;
begin
  try
    LControllerPlano:= TPlanoController.Create;
    Result:= LControllerPlano.GetNomePorId(LPlanoId, LStrErro);
    if (LStrErro <> '') and (LStrErro <> 'Erro ao buscar plano: 404') then
    begin
      ShowMessage(LStrErro);
      Tlibrary.GravarLog(LStrErro);
    end;
  finally
    LControllerPlano.Free;
  end;
end;

procedure TfrmCadastroLicencas.lstListagemDblClick(Sender: TObject);
var
  LStrErro: string;
  LValorLicenca: Double;
begin
  inherited;
  FLicencas:= FLicencasController.CarregarPorId(lstListagem.Items[lstListagem.Selected.Index].Tag, LStrErro);
  Tlibrary.ModelParaTela(FLicencas, lytCamposCadastro);
  LValorLicenca:= FLicencas.ValorTotal;
  // 1. Sincroniza o ComboBox de Planos
  cbbPlanos.ItemIndex := 0;
  for var I := 0 to cbbPlanos.Items.Count - 1 do
  begin
    if cbbPlanos.ListBox.ListItems[I].Tag = FLicencas.PlanoId then
    begin
      cbbPlanos.ItemIndex := I;
      Break;
    end;
  end;

  // 2. Sincroniza o ComboBox de Módulos (Se vier 0 do banco, cai na primeira opção "Nenhum")
  cbbModulos.ItemIndex := 0;
  for var I := 0 to cbbModulos.Items.Count - 1 do
  begin
    if cbbModulos.ListBox.ListItems[I].Tag = FLicencas.ModuloId then
    begin
      cbbModulos.ItemIndex := I;
      Break;
    end;
  end;

  // 3. Garante que as variáveis internas reflitam os valores atuais da licença trazida
  // (Puxa direto da model o valor acumulado salvo se o operador editou manualmente no passado)
  edtValorCobrado.Text := FormatFloat('#,##0.00', LValorLicenca);
  edtCodCliente.Text:= FLicencas.ClienteId.ToString;
  edtCodClienteExit(nil);
  tbcCampos.ActiveTab:= tbiCadastro;
  edtCodCliente.SetFocus;
end;

procedure TfrmCadastroLicencas.RecalcularTotalLicenca;
var
  LTotal: Double;
begin
  // Soma o valor base do plano com o valor adicional do nicho selecionado
  LTotal := fValorPlanoBase + fValorModuloBase;

  // Alimenta o Edit e a model
  edtValorCobrado.Text := FormatFloat('#,##0.00', LTotal);
  FLicencas.ValorTotal := LTotal;
end;

procedure TfrmCadastroLicencas.tbcCamposChange(Sender: TObject);
begin
  inherited;
  if tbcCampos.ActiveTab = tbiListagem then
    LimpaCampos;
end;

end.
