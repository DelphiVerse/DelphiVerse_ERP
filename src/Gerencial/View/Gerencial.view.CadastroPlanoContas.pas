unit Gerencial.view.CadastroPlanoContas;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.JSON,

  Gerencial.bases.BaseCadastros,
  Gerencial.model.PlanoContas,
  Gerencial.controller.PlanoContas,
  Gerencial.controller.Clientes,
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
  FMX.Layouts, FMX.Edit, FMX.ListBox;

type
  TfrmCadPlanoContas = class(TfrmBaseCadastros)
    edtNome: TEdit;
    lbl1: TLabel;
    swtStatus: TSwitch;
    lbl2: TLabel;
    lbl3: TLabel;
    cbbTipo: TComboBox;
    edtCodigoContabil: TEdit;
    Label1: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lblBtnCancelarClick(Sender: TObject);
    procedure lstListagemDblClick(Sender: TObject);
    procedure lblBtnGravarClick(Sender: TObject);
  private
    FPlanoContas: TPlanoContasModel;
    FPlanoContasController: TPlanoContasController;
    procedure CarregarLista;
    procedure LimpaCampos;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCadPlanoContas: TfrmCadPlanoContas;

implementation

{$R *.fmx}

procedure TfrmCadPlanoContas.CarregarLista;
var
  LStrErro,
  LNome,
  LCodigo,
  LTipo,
  LStatus: string;

  LJsonArray: TJSONArray;
  LItem: TListViewItem;
  I: Integer;
  LValue: TJSONValue;
  LId: Int64;
begin
  LJsonArray := FPlanoContasController.ListarTodos(LStrErro);

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

          // Extração segura do ID (Int64 / BigInt)
          LId := 0;
          if LValue.FindValue('id') <> nil then
            LId := StrToInt64Def(LValue.FindValue('id').Value, 0)
          else if LValue.FindValue('ID') <> nil then
            LId := StrToInt64Def(LValue.FindValue('ID').Value, 0);
          LItem.Tag := LId;

          // Extração dos textos do JSON
          LCodigo := '';
          if LValue.FindValue('codigoContabil') <> nil then LCodigo := LValue.FindValue('codigoContabil').Value
          else if LValue.FindValue('codigo_contabil') <> nil then LCodigo := LValue.FindValue('codigo_contabil').Value;

          LNome := '';
          if LValue.FindValue('nome') <> nil then LNome := LValue.FindValue('nome').Value;

          LTipo := '';
          if LValue.FindValue('tipo') <> nil then LTipo := LValue.FindValue('tipo').Value;

          LStatus := '';
          if LValue.FindValue('status') <> nil then LStatus := LValue.FindValue('status').Value;

          // Título principal: Nome da Categoria Financeira
          LItem.Text := LNome;

          // Subtítulo (Detail): Exibe o Código Contábil estruturado e o Tipo (Receita/Despesa)
          if LTipo.ToUpper = 'RECEITA' then
            LItem.Detail := Format(' [RECEITA] Código: %s', [LCodigo])
          else
            LItem.Detail := Format(' [DESPESA] Código: %s', [LCodigo]);

          // Opcional: Se o plano estiver inativo, adiciona um indicativo visual no texto
          if LStatus.ToUpper = 'I' then
            LItem.Text := LItem.Text + ' (INATIVO)';
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
    ShowMessage('Erro ao carregar plano de contas: ' + LStrErro);
  end;
end;

procedure TfrmCadPlanoContas.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action:= TCloseAction.caFree;
end;

procedure TfrmCadPlanoContas.FormCreate(Sender: TObject);
begin
  inherited;
  FPlanoContas := TPlanoContasModel.Create;
  FPlanoContasController := TPlanoContasController.Create;
  LimpaCampos;
  CarregarLista;
  tbcCampos.ActiveTab := tbiCadastro;
  Tlibrary.AjustaPosicaoBotoes(rctBotoes);
  edtNome.SetFocus;
end;

procedure TfrmCadPlanoContas.FormDestroy(Sender: TObject);
begin
  inherited;
  FPlanoContas.Free;
  FPlanoContasController.Free;
end;

procedure TfrmCadPlanoContas.lblBtnCancelarClick(Sender: TObject);
begin
  inherited;
  LimpaCampos;
end;

procedure TfrmCadPlanoContas.lblBtnGravarClick(Sender: TObject);
var
  lErro: string;
begin
  inherited;
  // 1. VALIDAÇÕES DE INTERFACE (UX DE SEGURANÇA)
  if edtNome.Text.Trim = '' then
  begin
    Tlibrary.MensagemCampoVazio('Nome');
    edtNome.SetFocus;
    Exit;
  end;

  if cbbTipo.ItemIndex = -1 then
  begin
    Tlibrary.MensagemCampoVazio('Tipo');
    cbbTipo.SetFocus;
    Exit;
  end;

  Tlibrary.TelaParaModel(FPlanoContas, lytCamposCadastro, False);

  FPlanoContas.Tipo      := cbbTipo.ListBox.ListItems[cbbTipo.ItemIndex].Text;

  FPlanoContas.DataCadastro := Now;

  // Tratamento manual do Switch de Status para String ('ATIVO'/'INATIVO')
  if swtStatus.IsChecked then
    FPlanoContas.Status := 'A'
  else
    FPlanoContas.Status := 'I';

  // 4. ENVIO PARA O BACK-END HORSE VIA CONTROLLER
  if not FPlanoContasController.Salvar(FPlanoContas, lErro) then
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

procedure TfrmCadPlanoContas.LimpaCampos;
begin
  FPlanoContas.Free;
  FPlanoContas := TPlanoContasModel.Create;
  Tlibrary.LimparTodosOsCampos(lytCamposCadastro);
  swtStatus.IsChecked := True;
  cbbTipo.ItemIndex:= -1;
  edtNome.SetFocus;
end;

procedure TfrmCadPlanoContas.lstListagemDblClick(Sender: TObject);
var
  LStrErro: string;
begin
  inherited;
  FPlanoContas:= FPlanoContasController.CarregarPorId(lstListagem.Items[lstListagem.Selected.Index].Tag, LStrErro);
  Tlibrary.ModelParaTela(FPlanoContas, lytCamposCadastro, False);
  cbbTipo.ItemIndex := 0;
  for var I := 0 to cbbTipo.Items.Count - 1 do
  begin
    if cbbTipo.ListBox.ListItems[I].Text = FPlanoContas.Tipo then
    begin
      cbbTipo.ItemIndex := I;
      Break;
    end;
  end;

  tbcCampos.ActiveTab:= tbiCadastro;
  edtNome.SetFocus;
end;

end.
