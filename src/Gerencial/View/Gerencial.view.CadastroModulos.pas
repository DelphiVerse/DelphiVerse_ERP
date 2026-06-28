unit Gerencial.view.CadastroModulos;

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
  FMX.Edit,
  FMX.ListView,
  FMX.TabControl,
  FMX.Controls.Presentation,
  FMX.Objects,
  FMX.Layouts,

  Gerencial.bases.BaseCadastros,
  Gerencial.model.Modulos,
  Gerencial.controller.Modulos,
  untLibrary,
  untConstantes;

type
  TfrmCadastroModulos = class(TfrmBaseCadastros)
    edtNome: TEdit;
    edtDescricao: TEdit;
    edtValorAdicional: TEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    swtStatus: TSwitch;
    lbl5: TLabel;
    edtChaveIdentificadora: TEdit;
    procedure FormShow(Sender: TObject);
    procedure lstListagemDblClick(Sender: TObject);
    procedure lblBtnGravarClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lblBtnCancelarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FModulos           : TModuloModel;
    FModulosController : TModuloController;
    procedure CarregarLista;
    procedure LimpaCampos;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCadastroModulos: TfrmCadastroModulos;

implementation

{$R *.fmx}

procedure TfrmCadastroModulos.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  Action:= TCloseAction.caFree;
end;

procedure TfrmCadastroModulos.FormCreate(Sender: TObject);
begin
  inherited;
  FModulos := TModuloModel.Create;
  FModulosController := TModuloController.Create;
  LimpaCampos;
  CarregarLista;
  tbcCampos.ActiveTab := tbiCadastro;
  Tlibrary.AjustaPosicaoBotoes(rctBotoes);
  edtNome.SetFocus;
end;

procedure TfrmCadastroModulos.FormDestroy(Sender: TObject);
begin
  inherited;
  FModulos.Free;
  FModulosController.Free;
end;

procedure TfrmCadastroModulos.FormShow(Sender: TObject);
begin
  inherited;
  lblTituloTela.Text:= frmCadastroModulos.Caption;
end;

procedure TfrmCadastroModulos.CarregarLista;
var
  LStrErro: string;
  LJsonArray: TJSONArray;
  LItem: TListViewItem;
  I: Integer;
  LValue: TJSONValue;
  LTempString: string;
  LTempId: Integer;
  LValor: Double;
begin
  LJsonArray := FModulosController.ListarTodos(LStrErro);
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

          if not LValue.TryGetValue<Integer>('id', LTempId) then
            LValue.TryGetValue<Integer>('ID', LTempId);

          LItem.Tag := LTempId;

          // Mapeamento do Nome do Módulo
          if LValue.TryGetValue<string>('nome', LTempString) then
            LItem.Text := LTempString
          else if LValue.TryGetValue<string>('NOME', LTempString) then
            LItem.Text := LTempString
          else
            LItem.Text := 'Módulo sem Nome';

          // Mapeamento do Subtítulo (Chave Identificadora + Valor Adicional)
          LTempString := '';
          if not LValue.TryGetValue<string>('chave_identificadora', LTempString) then
            LValue.TryGetValue<string>('chaveIdentificadora', LTempString);

          if not LValue.TryGetValue<Double>('valor_adicional', LValor) then
            LValue.TryGetValue<Double>('valorAdicional', LValor);

          LItem.Detail := 'Chave: ' + LTempString + ' | Adicional: ' + FormatCurr('R$ #,##0.00', LValor);
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

procedure TfrmCadastroModulos.LimpaCampos;
begin
  FModulos.Free;
  FModulos := TModuloModel.Create;
  Tlibrary.LimparTodosOsCampos(lytCamposCadastro);
  // Ajustes manuais específicos que não seguem a regra geral
//  lblID.Text:= 'ID:';
  swtStatus.IsChecked:= True;
  edtNome.SetFocus;
end;

procedure TfrmCadastroModulos.lblBtnCancelarClick(Sender: TObject);
begin
  inherited;
  LimpaCampos;
end;

procedure TfrmCadastroModulos.lblBtnGravarClick(Sender: TObject);
var
  lErro: string;
begin
  inherited;

  if edtNome.Text = '' then
  begin
    Tlibrary.MensagemCampoVazio('Nome');
    Exit;
  end;

  Tlibrary.TelaParaModel(FModulos, lytCamposCadastro);
  if not FModulosController.Salvar(FModulos, lErro) then
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

procedure TfrmCadastroModulos.lstListagemDblClick(Sender: TObject);
var
  lItem: TListViewItem;
  lErro: string;
begin
  inherited;
  if lstListagem.Selected = nil then
    Exit;

  lItem := TListViewItem(lstListagem.Selected);

  // 1. Libera a model antiga e carrega a nova com os dados completos do servidor
  FModulos.Free;
  FModulos := FModulosController.CarregarPorId(lItem.Tag, lErro);

  if lErro <> '' then
  begin
    ShowMessage('Ocorreu um erro ao buscar o módulo! ' + lErro);
    Exit;
  end;

  if Assigned(FModulos) then
  begin
    // 2. Agora o objeto tem Endereço, Bairro, etc., e o RTTI vai preencher a tela
    Tlibrary.ModelParaTela(FModulos, lytCamposCadastro);

    tbcCampos.ActiveTab := tbiCadastro;
//    lblID.Text:= 'ID: ' + IntToStr(lItem.Tag);
    edtNome.SetFocus;
  end
  else
    ShowMessage(lErro);
end;

end.
