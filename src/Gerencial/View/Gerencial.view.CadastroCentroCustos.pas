unit Gerencial.view.CadastroCentroCustos;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.JSON,

  Gerencial.bases.BaseCadastros,
  Gerencial.model.CentroCustos,
  Gerencial.controller.CentroCustos,
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
  FMX.Layouts, FMX.Edit;

type
  TfrmCadastroCentroCustos = class(TfrmBaseCadastros)
    edtNome: TEdit;
    lbl1: TLabel;
    swtStatus: TSwitch;
    lbl2: TLabel;
    procedure lblBtnGravarClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure lblBtnCancelarClick(Sender: TObject);
    procedure lstListagemDblClick(Sender: TObject);
  private
    FCentroCustos: TCentroCustosModel;
    FCentroCustosController: TCentroCustosController;
    procedure CarregarLista;
    procedure LimpaCampos;
    procedure ValidaCampos;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCadastroCentroCustos: TfrmCadastroCentroCustos;

implementation

{$R *.fmx}

procedure TfrmCadastroCentroCustos.CarregarLista;
var
  LStrErro: string;
  LJsonArray: TJSONArray;
  LItem: TListViewItem;
  I: Integer;
  LValue: TJSONValue;

  LId: Int64;
  LNome, LStatus: string;
begin
  LJsonArray := FCentroCustosController.ListarTodos(LStrErro);

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

          // ID (Int64)
          LId := 0;
          if LValue.FindValue('id') <> nil then
            LId := StrToInt64Def(LValue.FindValue('id').Value, 0);
          LItem.Tag := LId;

          // Nome e Status
          LNome := '';
          if LValue.FindValue('nome') <> nil then LNome := LValue.FindValue('nome').Value;

          LStatus := '';
          if LValue.FindValue('status') <> nil then LStatus := LValue.FindValue('status').Value;

          LItem.Text := LNome;

          if LStatus.ToUpper = 'A' then
            LItem.Detail := 'Centro de Custo Ativo'
          else
            LItem.Detail := 'Centro de Custo Inativo';
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
    ShowMessage('Erro ao carregar centro de custos: ' + LStrErro);
  end;
end;

procedure TfrmCadastroCentroCustos.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action:= TCloseAction.caFree;
end;

procedure TfrmCadastroCentroCustos.FormCreate(Sender: TObject);
begin
  inherited;
  FCentroCustos := TCentroCustosModel.Create;
  FCentroCustosController := TCentroCustosController.Create;
  LimpaCampos;
  CarregarLista;
  tbcCampos.ActiveTab := tbiCadastro;
  Tlibrary.AjustaPosicaoBotoes(rctBotoes);
  edtNome.SetFocus;
end;

procedure TfrmCadastroCentroCustos.FormDestroy(Sender: TObject);
begin
  inherited;
  FCentroCustos.Free;
  FCentroCustosController.Free;
end;

procedure TfrmCadastroCentroCustos.lblBtnCancelarClick(Sender: TObject);
begin
  inherited;
  LimpaCampos;
end;

procedure TfrmCadastroCentroCustos.ValidaCampos;
begin
  // 1. VALIDAÇÕES DE INTERFACE (UX DE SEGURANÇA)
  if edtNome.Text.Trim = '' then
  begin
    Tlibrary.MensagemCampoVazio('Nome');
    edtNome.SetFocus;
    Abort;
  end;
end;

procedure TfrmCadastroCentroCustos.lblBtnGravarClick(Sender: TObject);
var
  lErro: string;
begin
  inherited;
  ValidaCampos;
  Tlibrary.TelaParaModel(FCentroCustos, lytCamposCadastro, False);
  FCentroCustos.DataCadastro := Now;

  // Tratamento manual do Switch de Status para String ('ATIVO'/'INATIVO')
  if swtStatus.IsChecked then
    FCentroCustos.Status := 'A'
  else
    FCentroCustos.Status := 'I';

  // 4. ENVIO PARA O BACK-END HORSE VIA CONTROLLER
  if not FCentroCustosController.Salvar(FCentroCustos, lErro) then
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

procedure TfrmCadastroCentroCustos.LimpaCampos;
begin
  FCentroCustos.Free;
  FCentroCustos := TCentroCustosModel.Create;
  Tlibrary.LimparTodosOsCampos(lytCamposCadastro);
  swtStatus.IsChecked := True;
  edtNome.SetFocus;
end;

procedure TfrmCadastroCentroCustos.lstListagemDblClick(Sender: TObject);
var
  LStrErro: string;
begin
  inherited;
  FCentroCustos:= FCentroCustosController.CarregarPorId(lstListagem.Items[lstListagem.Selected.Index].Tag, LStrErro);
  Tlibrary.ModelParaTela(FCentroCustos, lytCamposCadastro, False);
  tbcCampos.ActiveTab:= tbiCadastro;
  edtNome.SetFocus;
end;

end.
