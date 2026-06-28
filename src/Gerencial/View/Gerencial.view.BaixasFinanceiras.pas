unit Gerencial.view.BaixasFinanceiras;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.JSON,
  System.Generics.Collections,

  untLibrary,
  Gerencial.controller.BaixasFinanceiras,
  Gerencial.model.BaixasFinanceiras,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Controls.Presentation,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Layouts,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.Edit,
  FMX.ExtCtrls,
  FMX.Menus,
  FMX.DialogService,
  FMX.DateTimeCtrls;

type
  TfrmBaixasFinanceiras = class(TForm)
    lytFundo: TLayout;
    rctFundo: TRectangle;
    lytTituloTela: TLayout;
    rctTituloJanela: TRectangle;
    lblTituloTela: TLabel;
    lytCentro: TLayout;
    lytBotoes: TLayout;
    rctBotoes: TRectangle;
    lytBtnGravar: TLayout;
    rctBtnGravar: TRectangle;
    lblBtnGravar: TLabel;
    lytBtnCancelar: TLayout;
    rctBtnCancelar: TRectangle;
    lblBtnCancelar: TLabel;
    lytBtnFechar: TLayout;
    rctBtnFechar: TRectangle;
    lblBtnFechar: TLabel;
    lstBaixas: TListView;
    lytCampos: TLayout;
    edtSaldo: TEdit;
    lbl1: TLabel;
    lytListagem: TLayout;
    lytBarraTituloListagem: TLayout;
    rctBarraTituloListagem: TRectangle;
    lbl2: TLabel;
    ppmOpcoes: TPopupMenu;
    mniAlterar: TMenuItem;
    mniExcluir: TMenuItem;
    edtDataBaixa: TDateEdit;
    lbl3: TLabel;
    edtValorMulta: TEdit;
    Label1: TLabel;
    edtValorJuros: TEdit;
    Label2: TLabel;
    edtValorDesconto: TEdit;
    Label3: TLabel;
    edtValorPago: TEdit;
    Label4: TLabel;
    pbxFormaPagamento: TPopupBox;
    lbl4: TLabel;
    procedure lblBtnFecharClick(Sender: TObject);
    procedure lblBtnGravarClick(Sender: TObject);
    procedure lblBtnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mniAlterarClick(Sender: TObject);
    procedure lstBaixasItemClickEx(const Sender: TObject; ItemIndex: Integer;
      const LocalClickPos: TPointF; const ItemObject: TListItemDrawable);
    procedure mniExcluirClick(Sender: TObject);
  private
    FIdBaixa: Integer;
    FBaixasFinanceirasController: TBaixasFinanceirasController;
    FBaixasFinanceiras: TBaixasFinanceirasModel;
    procedure LimpaCampos;
    procedure CarregarLista;
    procedure CalculaSaldo;
    { Private declarations }
  public
    { Public declarations }
    FIdLancamento: Integer;
    FValorOriginal, FValorPago: Double;
  end;

var
  frmBaixasFinanceiras: TfrmBaixasFinanceiras;

implementation

{$R *.fmx}

procedure TfrmBaixasFinanceiras.FormCreate(Sender: TObject);
begin
  FBaixasFinanceiras          := TBaixasFinanceirasModel.Create;
  FBaixasFinanceirasController:= TBaixasFinanceirasController.Create;
  Tlibrary.AjustaPosicaoBotoes(rctBotoes);
  FIdBaixa:= 0;
end;

procedure TfrmBaixasFinanceiras.FormDestroy(Sender: TObject);
begin
  FBaixasFinanceiras.Free;
  FBaixasFinanceirasController.Free;
end;

procedure TfrmBaixasFinanceiras.FormShow(Sender: TObject);
begin
  CarregarLista;
  CalculaSaldo;
end;

procedure TfrmBaixasFinanceiras.CalculaSaldo;
var
  LValorSaldo: Double;
begin
  LValorSaldo:= FValorOriginal - FValorPago;
  edtSaldo.Text:= FormatFloat('R$ #,##0.00', LValorSaldo);
end;

procedure TfrmBaixasFinanceiras.lblBtnCancelarClick(Sender: TObject);
begin
  LimpaCampos;
end;

procedure TfrmBaixasFinanceiras.CarregarLista;
var
  LStrErro: string;
  LJsonArray: TJSONArray;
  LItem: TListViewItem;
  I: Integer;
  LValue: TJSONValue;

  LId: Int64;
  LFormaPagamento, LDataBaixaStr, LDetailText: string;
  LValorPago, LValorJuros, LValorDesconto: Double;
begin
  // Trava de segurança: Se não houver um ID de lançamento Pai preenchido, aborta a busca
  if FIdLancamento <= 0 then
    Exit;

  // Chama a Controller passando especificamente o ID do lançamento financeiro
  LJsonArray := FBaixasFinanceirasController.ListarPorLancamento(FIdLancamento, LStrErro);

  if Assigned(LJsonArray) then
  begin
    try
      lstBaixas.BeginUpdate;
      try
        lstBaixas.Items.Clear;

        for I := 0 to LJsonArray.Count - 1 do
        begin
          LValue := LJsonArray.Items[I];
          LItem := lstBaixas.Items.Add;

          // 1. Extração segura do ID da Baixa (Int64)
          LId := 0;
          if LValue.FindValue('id') <> nil then LId := StrToInt64Def(LValue.FindValue('id').Value, 0);
          LItem.Tag := LId;

          // 2. Textos (Data e Forma de Pagamento)
          LFormaPagamento := '';
          if LValue.FindValue('formaPagamento') <> nil then LFormaPagamento := LValue.FindValue('formaPagamento').Value
          else if LValue.FindValue('forma_pagamento') <> nil then LFormaPagamento := LValue.FindValue('forma_pagamento').Value;

          LDataBaixaStr := '';
          if LValue.FindValue('dataBaixa') <> nil then LDataBaixaStr := LValue.FindValue('dataBaixa').Value
          else if LValue.FindValue('data_baixa') <> nil then LDataBaixaStr := LValue.FindValue('data_baixa').Value;

          // 3. Valores Financeiros (Usando TFormatSettings.Invariant)
          LValorPago := 0.00;
          if LValue.FindValue('valorPago') <> nil then LValorPago := StrToFloatDef(LValue.FindValue('valorPago').Value, 0.00, TFormatSettings.Invariant)
          else if LValue.FindValue('valor_pago') <> nil then LValorPago := StrToFloatDef(LValue.FindValue('valor_pago').Value, 0.00, TFormatSettings.Invariant);

          LValorJuros := 0.00;
          if LValue.FindValue('valorJuros') <> nil then LValorJuros := StrToFloatDef(LValue.FindValue('valorJuros').Value, 0.00, TFormatSettings.Invariant)
          else if LValue.FindValue('valor_juros') <> nil then LValorJuros := StrToFloatDef(LValue.FindValue('valor_juros').Value, 0.00, TFormatSettings.Invariant);

          LValorDesconto := 0.00;
          if LValue.FindValue('valorDesconto') <> nil then LValorDesconto := StrToFloatDef(LValue.FindValue('valorDesconto').Value, 0.00, TFormatSettings.Invariant)
          else if LValue.FindValue('valor_desconto') <> nil then LValorDesconto := StrToFloatDef(LValue.FindValue('valor_desconto').Value, 0.00, TFormatSettings.Invariant);

          // 4. Montagem do TÍTULO PRINCIPAL (Data formatada + Forma de Pagamento)
          if LDataBaixaStr.Length >= 10 then
            LItem.Text := ' ' + LDataBaixaStr.Substring(8,2) + '/' + LDataBaixaStr.Substring(5,2) + '/' + LDataBaixaStr.Substring(0,4) + ' - ' + LFormaPagamento
          else
            LItem.Text := ' ' + LFormaPagamento;

          // 5. Montagem do SUBTÍTULO (Detail)
          LDetailText := 'Pago: ' + FormatCurr('R$ #,##0.00', LValorPago);

          // Adiciona indicativos extras caso o cliente tenha pago com juros ou obtido desconto
          if LValorJuros > 0 then
            LDetailText := LDetailText + ' |  Juros: ' + FormatCurr('R$ #,##0.00', LValorJuros);

          if LValorDesconto > 0 then
            LDetailText := LDetailText + ' |  Desc: ' + FormatCurr('R$ #,##0.00', LValorDesconto);

          LItem.Detail := LDetailText;
        end;
      finally
        lstBaixas.EndUpdate;
        lstBaixas.Repaint;
      end;
    finally
      LJsonArray.Free;
    end;
  end
  else if LStrErro <> '' then
  begin
    ShowMessage('Erro ao carregar o histórico de baixas: ' + LStrErro);
  end;
end;

procedure TfrmBaixasFinanceiras.lblBtnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmBaixasFinanceiras.lblBtnGravarClick(Sender: TObject);
var
  LStrErro: string;
begin
  if FValorOriginal - FValorPago <= 0 then
  begin
    ShowMessage('Esse lançamento já está baixado!');
    Exit;
  end;
  LStrErro:= '';
  Tlibrary.TelaParaModel(FBaixasFinanceiras, lytCampos, False);
  FBaixasFinanceiras.LancamentoId := FIdLancamento;
  FBaixasFinanceiras.Id           := FIdBaixa;
  FBaixasFinanceirasController.Salvar(FBaixasFinanceiras, LStrErro);
  if LStrErro <> '' then
    ShowMessage('Ocorreu um erro ao efetuar a baixa: ' + LStrErro)
  else
  begin
    ShowMessage('Baixa gravada com sucesso!');
    Close;
  end;
end;

procedure TfrmBaixasFinanceiras.LimpaCampos;
begin
  FBaixasFinanceiras.Free;
  FBaixasFinanceiras := TBaixasFinanceirasModel.Create;
  Tlibrary.LimparTodosOsCampos(lytCentro);
  CalculaSaldo;
end;

procedure TfrmBaixasFinanceiras.lstBaixasItemClickEx(const Sender: TObject;
  ItemIndex: Integer; const LocalClickPos: TPointF;
  const ItemObject: TListItemDrawable);
var
  LPontoTela: TPointF;
begin
  // 1. Verifica se o usuário clicou em algum objeto válido dentro da linha
  if ItemObject = nil then
    Exit;

  // 2. Verifica se o objeto clicado foi o acessório '>' (cujo nome interno no FMX é 'accessory' ou 'detail')
  if (ItemObject.Name = 'accessory') or (ItemObject.Name = 'detail') or (ItemObject.Name = 'A')then
  begin
    // Força a seleção da linha onde o usuário clicou (garante que lstListagem.Selected fique correto)
    lstBaixas.ItemIndex := ItemIndex;

    // Converte a posição do clique (que é local do ListView) para a posição Global da Tela
    LPontoTela := lstBaixas.LocalToScreen(LocalClickPos);

    // Abre o PopupMenu exatamente na ponta do dedo/mouse do usuário
    ppmOpcoes.Popup(LPontoTela.X, LPontoTela.Y);
  end;
end;

procedure TfrmBaixasFinanceiras.mniAlterarClick(Sender: TObject);
begin
  if lstBaixas.Selected = nil then
    Exit;

  // Pega o ID que guardamos na Tag da linha
  var LIdSelecionado := lstBaixas.Selected.Tag;

  FBaixasFinanceiras := FBaixasFinanceirasController.CarregarPorId(LIdSelecionado);
  // Joga os dados da model para a tela usando
  Tlibrary.ModelParaTela(FBaixasFinanceiras, lytCampos, False);
  FIdBaixa:= FBaixasFinanceiras.Id;
end;

procedure TfrmBaixasFinanceiras.mniExcluirClick(Sender: TObject);
var
  LErro: string;
begin
  if lstBaixas.Selected = nil then
    Exit;

  // Pede confirmação antes de excluir (Boa prática)
  // No FMX Mobile, pode usar TDialogService.MessageDialog se preferir
   TDialogService.MessageDialog('Deseja realmente excluir este registro?',
             TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
             procedure (const AResult: TModalResult)
             begin
               if AResult = mrYes then
               begin
                 if FBaixasFinanceirasController.Excluir(lstBaixas.Selected.Tag, LErro) then
                 begin
                   ShowMessage('Registro excluído com sucesso!');
                  CarregarLista; // Atualiza a lista para o item sumir
                 end
                 else
                   ShowMessage('Erro ao excluir: ' + LErro);
               end
               else
               begin

               end;
             end);
end;

end.
