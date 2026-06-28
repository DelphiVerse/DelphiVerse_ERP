unit Gerencial.view.PesquisaClientes;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.JSON,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.Edit,
  FMX.Objects,
  FMX.Layouts,
  FMX.StdCtrls,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,

  Gerencial.controller.Clientes;

type
  TfrmPesquisaClientes = class(TForm)
    lytFundo: TLayout;
    rctFundo: TRectangle;
    lytTopo: TLayout;
    edtBusca: TEdit;
    btnPesquisar: TSpeedButton;
    lytBotoes: TLayout;
    lytResultados: TLayout;
    lstResultados: TListView;
    btnSelecionar: TButton;
    lytBtnGravar: TLayout;
    rctBtnGravar: TRectangle;
    lblBtnGravar: TLabel;
    lytBtnCancelar: TLayout;
    rctBtnCancelar: TRectangle;
    lblBtnCancelar: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure edtBuscaKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: WideChar; Shift: TShiftState);
    procedure btnPesquisarClick(Sender: TObject);
    procedure lstResultadosDblClick(Sender: TObject);
    procedure lblBtnGravarClick(Sender: TObject);
    procedure lblBtnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FClienteController: TClienteController;
    FClienteSelecionadoId: Integer;
    FClienteSelecionadoNome: string;
    procedure ExecutarBusca;
  public
    { Public declarations }
    { Propriedades expostas para o formulário que chamou a pesquisa }
    property ClienteSelecionadoId: Integer read FClienteSelecionadoId;
    property ClienteSelecionadoNome: string read FClienteSelecionadoNome;
  end;

var
  frmPesquisaClientes: TfrmPesquisaClientes;

implementation

{$R *.fmx}

procedure TfrmPesquisaClientes.btnPesquisarClick(Sender: TObject);
begin
  ExecutarBusca;
end;

procedure TfrmPesquisaClientes.edtBuscaKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  // Se pressionar Enter no campo de texto, dispara a busca
  if Key = vkReturn then
    ExecutarBusca;
end;

procedure TfrmPesquisaClientes.ExecutarBusca;
var
  LStrErro: string;
  LJsonArray: TJSONArray;
  LItem: TListViewItem;
  LValue: TJSONValue;
  LId: Integer;
  LRazao, LCpfCnpj: string;
begin
  if edtBusca.Text.Trim.Length < 3 then
  begin
    ShowMessage('Digite pelo menos 3 caracteres para pesquisar.');
    edtBusca.SetFocus;
    Exit;
  end;

  // Busca o JSON Array na sua Controller
  LJsonArray := FClienteController.ListarTodos(LStrErro);

  if Assigned(LJsonArray) then
  begin
    try
      lstResultados.BeginUpdate;
      try
        lstResultados.Items.Clear;

        for var I := 0 to LJsonArray.Count - 1 do
        begin
          LValue := LJsonArray.Items[I];

          // 1. EXTRAÇÃO ULTRA RESILIENTE DO ID (Evita que o TryGetValue quebre por tipo)
          LId := 0;
          if LValue.FindValue('id') <> nil then
            LId := StrToIntDef(LValue.FindValue('id').Value, 0)
          else if LValue.FindValue('ID') <> nil then
            LId := StrToIntDef(LValue.FindValue('ID').Value, 0);

          // 2. EXTRAÇÃO RESILIENTE DA RAZÃO SOCIAL (Testa CamelCase, Underline e Maiúsculas)
          LRazao := '';
          if LValue.FindValue('razaoSocial') <> nil then
            LRazao := LValue.FindValue('razaoSocial').Value
          else if LValue.FindValue('razao_social') <> nil then
            LRazao := LValue.FindValue('razao_social').Value
          else if LValue.FindValue('RAZAO_SOCIAL') <> nil then
            LRazao := LValue.FindValue('RAZAO_SOCIAL').Value;

          // 3. EXTRAÇÃO RESILIENTE DO CPF/CNPJ
          LCpfCnpj := '';
          if LValue.FindValue('cpfCnpj') <> nil then
            LCpfCnpj := LValue.FindValue('cpfCnpj').Value
          else if LValue.FindValue('cpf_cnpj') <> nil then
            LCpfCnpj := LValue.FindValue('cpf_cnpj').Value
          else if LValue.FindValue('CPF_CNPJ') <> nil then
            LCpfCnpj := LValue.FindValue('CPF_CNPJ').Value;

          // Se não conseguiu resgatar um ID válido ou Razão Social vazia, pula o registro por segurança
          if (LId = 0) or (LRazao = '') then
            Continue;

          // 4. FILTRO LOCAL TEMPORÁRIO (Ignora caso não dê o match parcial do texto)
          if (edtBusca.Text <> '') and (not LRazao.ToLower.Contains(edtBusca.Text.ToLower)) then
            Continue;

          // 5. INSERÇÃO PERFEITA NO TLISTVIEW
          LItem := TListViewItem(lstResultados.Items.Add); // Realiza o cast explícito nativo
          LItem.Tag := LId;
          LItem.Text := LRazao;
          LItem.Detail := 'Doc: ' + LCpfCnpj;
        end;
      finally
        lstResultados.EndUpdate;
        lstResultados.Repaint;
      end;
    finally
      LJsonArray.Free;
    end;
  end
  else if LStrErro <> '' then
  begin
    ShowMessage('Erro na comunicação: ' + LStrErro);
  end;
end;

procedure TfrmPesquisaClientes.FormCreate(Sender: TObject);
begin
  FClienteController := TClienteController.Create;
  FClienteSelecionadoId := 0;
  FClienteSelecionadoNome := '';
end;

procedure TfrmPesquisaClientes.FormShow(Sender: TObject);
begin
  edtBusca.SetFocus;
end;

procedure TfrmPesquisaClientes.lblBtnCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmPesquisaClientes.lblBtnGravarClick(Sender: TObject);
var
  LItem: TListViewItem; // Variável local para isolar o item selecionado
begin
  if lstResultados.Selected = nil then
  begin
    ShowMessage('Selecione um cliente na lista.');
    Exit;
  end;

  // Fazemos o Casting explícito do item selecionado para TListViewItem
  LItem := TListViewItem(lstResultados.Selected);

  // Agora o Delphi vai reconhecer o .Tag e o .Text perfeitamente!
  FClienteSelecionadoId   := LItem.Tag;
  FClienteSelecionadoNome := LItem.Text;

  ModalResult := mrOk; // Fecha a tela informando sucesso
end;

procedure TfrmPesquisaClientes.lstResultadosDblClick(Sender: TObject);
begin
  lblBtnGravarClick(Sender);
end;

end.
