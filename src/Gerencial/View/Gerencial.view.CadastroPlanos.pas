unit Gerencial.view.CadastroPlanos;

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
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.TabControl,
  FMX.Controls.Presentation,
  FMX.Objects,
  FMX.Layouts,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.Edit,

  Gerencial.bases.BaseCadastros,
  Gerencial.model.Planos,
  GErencial.controller.Planos,
  untLibrary, untConstantes;

type
  TfrmCadastroPlanos = class(TfrmBaseCadastros)
    edtNome: TEdit;
    lblNome: TLabel;
    edtDescricao: TEdit;
    lbl1: TLabel;
    edtValorBase: TEdit;
    Label1: TLabel;
    edtLimiteUsuarios: TEdit;
    Label2: TLabel;
    swtStatus: TSwitch;
    Label3: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lstListagemDblClick(Sender: TObject);
    procedure lblBtnGravarClick(Sender: TObject);
    procedure lblBtnCancelarClick(Sender: TObject);
  private
    FPlanos           : TPlanoModel;
    FPlanosController : TPlanoController;
    procedure CarregarLista;
    procedure LimpaCampos;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCadastroPlanos: TfrmCadastroPlanos;

implementation

{$R *.fmx}

procedure TfrmCadastroPlanos.CarregarLista;
var
  LStrErro: string;
  LJsonArray: TJSONArray;
  LItem: TListViewItem;
  I: Integer;
  LValue: TJSONValue;
  LNome, LDesc: string;
  LValor: Double;
  LId, LUserLimit: Integer;
begin
  LJsonArray := FPlanosController.ListarTodos(LStrErro);
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

          // Resiliência de chaves minúsculas/maiúsculas
          if not LValue.TryGetValue<Integer>('id', LId) then LValue.TryGetValue<Integer>('ID', LId);
          if not LValue.TryGetValue<string>('nome', LNome) then LValue.TryGetValue<string>('NOME', LNome);
          if not LValue.TryGetValue<Double>('valor_base', LValor) then LValue.TryGetValue<Double>('valorBase', LValor);
          if not LValue.TryGetValue<Integer>('limite_usuarios', LUserLimit) then LValue.TryGetValue<Integer>('limiteUsuarios', LUserLimit);

          LItem.Tag := LId;
          LItem.Text := LNome;

          // Detalhe elegante exibindo o valor e o limite de acessos do plano
          LItem.Detail := FormatCurr('R$ #,##0.00', LValor) + ' | Limite: ' + LUserLimit.ToString + ' Usuário(s)';
        end;
      finally
        lstListagem.EndUpdate;
        lstListagem.Repaint;
      end;
    finally
      LJsonArray.Free;
    end;
  end;
end;

procedure TfrmCadastroPlanos.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action:= TCloseAction.caFree;
end;

procedure TfrmCadastroPlanos.FormCreate(Sender: TObject);
begin
  inherited;
  FPlanos := TPlanoModel.Create;
  FPlanosController := TPlanoController.Create;
  LimpaCampos;
  CarregarLista;
  tbcCampos.ActiveTab := tbiCadastro;
  Tlibrary.AjustaPosicaoBotoes(rctBotoes);
//  edtNome.SetFocus;
end;

procedure TfrmCadastroPlanos.FormDestroy(Sender: TObject);
begin
  inherited;
  FPlanos.Free;
  FPlanosController.Free;
end;

procedure TfrmCadastroPlanos.lblBtnCancelarClick(Sender: TObject);
begin
  inherited;
  LimpaCampos;
end;

procedure TfrmCadastroPlanos.lblBtnGravarClick(Sender: TObject);
var
  lErro: string;
begin
  inherited;

  if edtNome.Text = '' then
  begin
    Tlibrary.MensagemCampoVazio('Nome');
    Exit;
  end;

  Tlibrary.TelaParaModel(FPlanos, lytCamposCadastro);
  if not FPlanosController.Salvar(FPlanos, lErro) then
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

procedure TfrmCadastroPlanos.LimpaCampos;
begin
  FPlanos.Free;
  FPlanos := TPlanoModel.Create;
  Tlibrary.LimparTodosOsCampos(lytCamposCadastro);
  // Ajustes manuais específicos que não seguem a regra geral
//  lblID.Text:= 'ID:';
//  swtStatus.IsChecked:= True;
  edtNome.SetFocus;
end;

procedure TfrmCadastroPlanos.lstListagemDblClick(Sender: TObject);
var
  lItem: TListViewItem;
  lErro: string;
begin
  inherited;
  if lstListagem.Selected = nil then
    Exit;

  lItem := TListViewItem(lstListagem.Selected);

  // 1. Libera a model antiga e carrega a nova com os dados completos do servidor
  FPlanos.Free;
  FPlanos := FPlanosController.CarregarPorId(lItem.Tag, lErro);

  if lErro <> '' then
  begin
    ShowMessage('Ocorreu um erro ao buscar o módulo! ' + lErro);
    Exit;
  end;

  if Assigned(FPlanos) then
  begin
    // 2. Agora o objeto tem Endereço, Bairro, etc., e o RTTI vai preencher a tela
    Tlibrary.ModelParaTela(FPlanos, lytCamposCadastro);

    tbcCampos.ActiveTab := tbiCadastro;
//    lblID.Text:= 'ID: ' + IntToStr(lItem.Tag);
    edtNome.SetFocus;
  end
  else
    ShowMessage(lErro);
end;
end.
