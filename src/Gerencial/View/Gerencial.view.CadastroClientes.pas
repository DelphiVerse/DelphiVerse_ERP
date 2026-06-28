unit Gerencial.view.CadastroClientes;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.JSON,
  System.Net.HttpClient,

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
  FMX.Edit,
  FMX.ListBox,

  Gerencial.bases.BaseCadastros,
  Gerencial.utils.Validacoes,
  Gerencial.model.Clientes,
  Gerencial.controller.Clientes,

  untLibrary,
  untConstantes;

type
  TfrmCadastroClientes = class(TfrmBaseCadastros)
    edtRazaoSocial: TEdit;
    lblRazaoSocial: TLabel;
    edtNomeFantasia: TEdit;
    lblNomeFantasia: TLabel;
    edtCpfCnpj: TEdit;
    lblCpfCnpj: TLabel;
    edtRgIe: TEdit;
    lblRgIe: TLabel;
    lbl2: TLabel;
    cbbTipoPessoa: TComboBox;
    swtStatus: TSwitch;
    lbl1: TLabel;
	  edtEmail: TEdit;
    lblEmail: TLabel;
    edtTelefone: TEdit;
    lblTelefone: TLabel;
    edtCep: TEdit;
    lblCep: TLabel;
    edtEndereco: TEdit;
    lblEndereco: TLabel;
    edtNumero: TEdit;
    lblNumero: TLabel;
    edtBairro: TEdit;
    lblBairro: TLabel;
    edtCidade: TEdit;
    lblCidade: TLabel;
    edtUf: TEdit;
    lblUf: TLabel;
    edtObservacoes: TEdit;
    lblObservacoes: TLabel;
    lbl3: TLabel;
    edtComplemento: TEdit;
    lblID: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lblBtnCancelarClick(Sender: TObject);
    procedure edtCpfCnpjExit(Sender: TObject);
    procedure cbbTipoPessoaClosePopup(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lblBtnGravarClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtRazaoSocialExit(Sender: TObject);
    procedure lstListagemDblClick(Sender: TObject);
  private
    FClientes           : TClienteModel;
    FClientesController : TClienteController;
    procedure LimpaCampos;
    procedure CarregarLista;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCadastroClientes: TfrmCadastroClientes;

implementation

uses
  Gerencial.view.Principal;

{$R *.fmx}

procedure TfrmCadastroClientes.cbbTipoPessoaClosePopup(Sender: TObject);
begin
  inherited;
  if cbbTipoPessoa.ItemIndex = 0 then
  begin
    lblRazaoSocial.Text       := 'Nome';
    edtRazaoSocial.TextPrompt := 'Nome';
    lblNomeFantasia.Text      := 'Nome Fantasia (Apelido)';
    edtNomeFantasia.TextPrompt:= 'Nome Fantasia (Apelido)';
    lblCpfCnpj.Text           := 'CPF';
    edtCpfCnpj.TextPrompt     := 'CPF';
    lblRgIe.Text              := 'RG';
    edtRgIe.TextPrompt        := 'RG';
  end
  else
  begin
    lblRazaoSocial.Text       := 'Razão Social';
    edtRazaoSocial.TextPrompt := 'Razão Social';
    lblNomeFantasia.Text      := 'Nome Fantasia';
    edtNomeFantasia.TextPrompt:= 'Nome Fantasia';
    lblCpfCnpj.Text           := 'CNPJ';
    edtCpfCnpj.TextPrompt     := 'CNPJ';
    lblRgIe.Text              := 'Inscrição Estadual';
    edtRgIe.TextPrompt        := 'Inscrição Estadual';
  end;
end;

procedure TfrmCadastroClientes.edtCpfCnpjExit(Sender: TObject);
begin
  inherited;
  if not TValidacao.DocumentoEhValido(edtCpfCnpj.Text) then
  begin
    ShowMessage('CPF ou CNPJ inválido!');
    edtCpfCnpj.SetFocus;
    Exit;
  end;
end;

procedure TfrmCadastroClientes.edtRazaoSocialExit(Sender: TObject);
begin
  inherited;
  if cbbTipoPessoa.ItemIndex = 0 then
    edtNomeFantasia.Text := edtRazaoSocial.Text;
end;

procedure TfrmCadastroClientes.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action:= TCloseAction.caFree;
end;

procedure TfrmCadastroClientes.FormCreate(Sender: TObject);
begin
  inherited;
  FClientes:= TClienteModel.Create;
  FClientesController:= TClienteController.Create;
  LimpaCampos;
  CarregarLista;
  tbcCampos.ActiveTab:= tbiCadastro;
  Tlibrary.AjustaPosicaoBotoes(rctBotoes);
  edtRazaoSocial.SetFocus;
end;

procedure TfrmCadastroClientes.FormDestroy(Sender: TObject);
begin
  inherited;
  FClientes.Free;
  FClientesController.Free;
end;

procedure TfrmCadastroClientes.lblBtnCancelarClick(Sender: TObject);
begin
  inherited;
  LimpaCampos;
end;

procedure TfrmCadastroClientes.lblBtnGravarClick(Sender: TObject);
var
  lErro: string;
begin
  inherited;

  if edtRazaoSocial.Text = '' then
  begin
    Tlibrary.MensagemCampoVazio('Razão Social');
    Exit;
  end;

  Tlibrary.TelaParaModel(FClientes, lytCamposCadastro);
  if not FClientesController.Salvar(FClientes, lErro) then
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

procedure TfrmCadastroClientes.CarregarLista;
var
  LStrErro: string;
  LJsonArray: TJSONArray;
  LItem: TListViewItem;
  I: Integer;
  LValue: TJSONValue;
  LTempString: string;
  LTempId: Integer;
begin
  LJsonArray := FClientesController.ListarTodos(LStrErro);
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

          // Guardamos o ID no Tag para quando o usuário clicar no item
          if not LValue.TryGetValue<Integer>('id', LTempId) then
            LValue.TryGetValue<Integer>('ID', LTempId);

          LItem.Tag := LTempId;

          // Mapeamento baseado nos nomes das colunas da sua tabela 'clientes'
          // Tenta as variações comuns
          if LValue.TryGetValue<string>('razao_social', LTempString) then
            LItem.Text := LTempString
          else if LValue.TryGetValue<string>('RAZAO_SOCIAL', LTempString) then
            LItem.Text := LTempString
          else if LValue.TryGetValue<string>('razaoSocial', LTempString) then // camelCase
            LItem.Text := IntToStr(LItem.Tag) + ' - ' + LTempString
          else
            // Se chegar aqui, vamos mostrar o JSON bruto na linha para descobrir o nome real da chave
            ShowMessage('Chave não encontrada: ' + LValue.ToString);

          // No Detail, vamos colocar o CPF/CNPJ e Cidade
          LTempString := '';
          if not LValue.TryGetValue<string>('cpfCnpj', LTempString) then
            LValue.TryGetValue<string>('CPF_CNPJ', LTempString);

          LItem.Detail := 'Doc: ' + LTempString + ' - ';

          LTempString := '';
          if not LValue.TryGetValue<string>('cidade', LTempString) then
            LValue.TryGetValue<string>('CIDADE', LTempString);

          LItem.Detail := LItem.Detail + LTempString;

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
    ShowMessage(LStrErro);
  end;
end;

procedure TfrmCadastroClientes.LimpaCampos;
begin
  FClientes.Free;
  FClientes := TClienteModel.Create;
  Tlibrary.LimparTodosOsCampos(lytCamposCadastro);
  // Ajustes manuais específicos que não seguem a regra geral
  lblID.Text:= 'ID:';
  swtStatus.IsChecked:= True;
  cbbTipoPessoa.ItemIndex := 0;
  cbbTipoPessoaClosePopup(nil); // Para resetar os Labels (CPF/CNPJ)
  edtRazaoSocial.SetFocus;
end;

procedure TfrmCadastroClientes.lstListagemDblClick(Sender: TObject);
var
  lItem: TListViewItem;
  lErro: string;
begin
  if lstListagem.Selected = nil then
    Exit;

  lItem := TListViewItem(lstListagem.Selected);

  // 1. Libera a model antiga e carrega a nova com os dados completos do servidor
  FClientes.Free;
  FClientes := FClientesController.CarregarPorId(lItem.Tag, lErro);

  if lErro <> '' then
  begin
    ShowMessage('Ocorreu um erro ao buscar o cliente! ' + lErro);
    Exit;
  end;

  if Assigned(FClientes) then
  begin
    // 2. Agora o objeto tem Endereço, Bairro, etc., e o RTTI vai preencher a tela
    Tlibrary.ModelParaTela(FClientes, lytCamposCadastro);

    tbcCampos.ActiveTab := tbiCadastro;
    lblID.Text:= 'ID: ' + IntToStr(lItem.Tag);
    edtRazaoSocial.SetFocus;
  end
  else
    ShowMessage(lErro);
end;

end.
