unit IntellisoftERP.bases.BaseCadastros;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Generics.Collections,

  FMX.Types,
  FMX.Graphics,
  FMX.Controls,
  FMX.Forms,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Objects,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.ListView,
  FMX.TabControl;

type
  TfrmBaseCadastro = class(TFrame)
    lytFundo: TLayout;
    rctFundo: TRectangle;
    lytTituloTela: TLayout;
    rctTituloJanela: TRectangle;
    lblTituloTela: TLabel;
    lytCentro: TLayout;
    tbcCampos: TTabControl;
    tbiCadastro: TTabItem;
    tbiListagem: TTabItem;
    rctTbiCadastro: TRectangle;
    rctTbiListagem: TRectangle;
    lstListagem: TListView;
    lytBotoes: TLayout;
    rctBotoes: TRectangle;
    lytBtnGravar: TLayout;
    rctBtnGravar: TRectangle;
    lytBtnCancelar: TLayout;
    lytBtnExcluir: TLayout;
    lytBtnFechar: TLayout;
    rctBtnCancelar: TRectangle;
    rctBtnExcluir: TRectangle;
    rctBtnFechar: TRectangle;
    lblBtnFechar: TLabel;
    lblBtnExcluir: TLabel;
    lblBtnCancelar: TLabel;
    lblBtnGravar: TLabel;
    procedure rctBtnFecharClick(Sender: TObject);
    procedure FrameResized(Sender: TObject);
  private
    procedure CentralizarBotoes(aRectangle: TRectangle);
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

procedure TfrmBaseCadastro.FrameResized(Sender: TObject);
begin
  CentralizarBotoes(rctBotoes);
end;

procedure TfrmBaseCadastro.rctBtnFecharClick(Sender: TObject);
begin
  Self.Parent:= nil;
  Self.DisposeOf;
end;

procedure TfrmBaseCadastro.CentralizarBotoes(aRectangle: TRectangle);
var
  I, Count: Integer;
  Botao: TControl;
  Espacamento, PosicaoX: Single;
  ListaBotoes: TList<TControl>;
begin
  ListaBotoes := TList<TControl>.Create;
  try
    // 1. Coleta apenas os controles visíveis que não são o próprio layout
    for I := 0 to aRectangle.ControlsCount - 1 do
    begin
      if aRectangle.Controls[I] is TLayout then
        ListaBotoes.Add(aRectangle.Controls[I]);
    end;

    Count := ListaBotoes.Count;
    if Count = 0 then Exit;

    // 2. Calcula o espaçamento necessário (n + 1 espaços)
    // Usamos 400 como largura fixa conforme solicitado
    Espacamento := (aRectangle.Width - (Count * 100)) / (Count + 1);

    // 3. Posiciona cada botão
    PosicaoX := Espacamento;
    for I := 0 to Count - 1 do
    begin
      Botao := ListaBotoes[I];
      Botao.Position.X := PosicaoX;

      // Garante que o alinhamento não interfira no posicionamento manual
      Botao.Align := TAlignLayout.None;
//      Botao.Width := 100;

      // Incrementa a posição para o próximo botão
      PosicaoX := PosicaoX + 100 + Espacamento;
    end;
  finally
    ListaBotoes.Free;
  end;
end;

end.
