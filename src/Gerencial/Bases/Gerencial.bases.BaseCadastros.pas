unit Gerencial.bases.BaseCadastros;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.TabControl, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts;

type
  TfrmBaseCadastros = class(TForm)
    lytFundo: TLayout;
    rctFundo: TRectangle;
    lytTituloTela: TLayout;
    rctTituloJanela: TRectangle;
    lblTituloTela: TLabel;
    lytCentro: TLayout;
    tbcCampos: TTabControl;
    tbiCadastro: TTabItem;
    rctTbiCadastro: TRectangle;
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
    tbiListagem: TTabItem;
    rctTbiListagem: TRectangle;
    lstListagem: TListView;
    lytCamposCadastro: TLayout;
    procedure lblBtnFecharClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmBaseCadastros: TfrmBaseCadastros;

implementation

{$R *.fmx}

procedure TfrmBaseCadastros.lblBtnFecharClick(Sender: TObject);
begin
  lytFundo.Parent:= Self;
  Self.Close;
end;

end.
