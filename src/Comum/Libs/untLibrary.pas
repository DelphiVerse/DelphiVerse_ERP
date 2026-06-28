unit untLibrary;

interface

uses
  System.IOUtils,
  System.RegularExpressions,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,
  System.Rtti,
  System.Bindings.Outputs,

  Data.Bind.EngExt,
  Data.Bind.Components,
  Data.Bind.DBScope,
  Data.DB,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,

  FMX.Edit,
  FMX.Objects,
  FMX.Forms,
  FMX.Layouts,
  FMX.Controls,
  FMX.Types,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.ListView.Types,
  FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base,
  FMX.Controls.Presentation,
  FMX.ListView,
  FMX.ListBox,
  Fmx.Bind.Editors,
  Fmx.Bind.DBEngExt,

  untBase,
  IniFiles,
  untPrincipal,
  untDM,
  untConstantes;

type
  Tlibrary = class
    private
       class var
         FOnLine : Boolean;
         FIP, FPorta: string;
    class procedure MensagemCampoVazio(const AMEensagem: string); static;
    public
      {Varãveis}
      //FActiveForm: TForm;
      {Métodos}
//      class procedure ValidaCampo(const ACampo: TEdit; const ALinha: TLine; const ATipoVAlidacao: TTipoValidacao);
      class procedure LerConfig;
      class procedure SalvarConfg(const AIP: string; APorta: string);
      class procedure AjustaForm(const AForm: TForm; ALayout: TLayout);
      class procedure AbrirForm(const AFormClass: TComponentClass);
      class function AjustaDataSql(const ADataStr, Controle : string) : string;
//      class function EnviaParaBanco(const AOrigemDados : TRESTDWClientSQL): string;
      class procedure ExpandeMenu(const Menu : TListBox);
//      class procedure GravarDados(const ATabela : string; const ADm:TdmRestDW; const AMemTable : TFDMemTable);
//      class procedure CarregaDados(const ATabela : string; const ADm: TdmRestDW; const AMemTable : TFDMemTable; const AParams: TDWParams); overload;
//      class procedure CarregaDados(const ATabela : string; const ADm : TdmRestDW; const AMemTable : TFDMemTable); overload;
//      class function GetDadosRelatorioGeral(const ALote: string; const ADataIni, ADataFim : TDate; const AEvento : string; const AMemTable : TFDMemTable) : string;
//      class function CarregaPesquisa(const AEvento : string; const AMemTable : TFDMemTable): string;
      class function CalculaImpostos(const AAliquota, ABaseCalculo : double) : double;
      class procedure MarcaParaExclusao(const AMemTable : TFDMemTable);
//      class procedure GravaMemTable (const AMemTable : TFDMemTable);
      class function MascaraData(const AData : string) : string;
//      class procedure AbrirPesquisa(const ADm: TdmRestDW; const ATabela : string);
//      class procedure AbrirRelatorioGeral(const ARelatorio : string; const ALote, AGranja : string);
      class procedure InsereBarra(ACampoEdit : TEdit; var Key: Word; var KeyChar: Char; Shift: TShiftState);
      class procedure MensagemEditVazio(var ACampo : TEdit);
      class procedure PreparaInsersao(const AMemTable : TFDMemTable);
      class function ConcatenaInteiros(const AInteiro1, AInteiro2 : Word): integer;
      class procedure MensagemErroGravacao(const AErro: string);
      class function FiltrarPelaId(const AMemTable: TFDMemTable; AId: string): Boolean;
      class function FiltrarPet(const AMemTable: TFDMemTable; AId: string; AIdCliente: string): Boolean;
      //class procedure EntraEdit(obj: TObject);
      //class procedure SaiEdit(const AEdit: TEdit);

      {Propriedades}
      //class property OnLine : Boolean read FOnline write FOnLine;
      class property IP : string read FIP write FIP;
      class property Porta : string read FPorta write FPorta;
  end;

implementation

{ TLibrary }

uses untPesquisaDados, untLogMemo;

class procedure Tlibrary.MensagemCampoVazio(const AMEensagem: string);
begin
  ShowMessage(Format(_MENSAGEM_CAMPO_VAZIO, [AMEensagem]));
end;

class procedure Tlibrary.AbrirForm(const AFormClass: TComponentClass);
var FActiveForm: TForm;
begin
  if (assigned(FActiveForm)) then
  begin
    Application.CreateForm(AFormClass, FActiveForm);

  end;
end;
{
class procedure Tlibrary.AbrirPesquisa(const ADm: TdmRestDW; const ATabela: string);
begin
  Application.CreateForm(TfrmPesquisaDados, frmPesquisaDados);
  frmPesquisaDados.ADmDW  := ADm;
  frmPesquisaDados.Tabela := ATabela;
  frmPesquisaDados.ShowModal;
end;     }

{class procedure Tlibrary.AbrirRelatorioGeral(const ARelatorio: string; const ALote, AGranja : string);
Var
 lErro        : String;
 StringStream : TStringStream;
 MemoryStream : TMemoryStream;
Begin
 DWParams                   := TDWParams.Create;
 dmRestDW.DWClientEvents.CreateDWParams('arq_relatorio_geral', dwParams);
 DWParams.ItemsString['id_lote'].AsString := ALote;
 DWParams.ItemsString['id_granja'].AsString := AGranja;
 Try
  Try
   dmRestDW.DWClientEvents.SendEvent(ARelatorio, dwParams, lErro);
   If lErro = '' Then
    Begin
     StringStream          := TStringStream.Create;
     dwParams.ItemsString['relatorio'].SaveToStream(StringStream);
     Try

      ForceDirectories('.\temp\');
      If FileExists('.\temp\RelatorioGeral.pdf') Then
       DeleteFile('.\temp\RelatorioGeral.pdf');

      StringStream.Position  := 0;
      StringStream.SaveToFile('.\temp\RelatorioGeral.pdf');
      StringStream.SetSize(0);

     Finally
      FreeAndNil(StringStream);
     End;
    End;
  Except
  End;
 Finally
  FreeAndNil(DWParams);
 End;

end;  }

class function Tlibrary.AjustaDataSql(const ADataStr, Controle: string): string;
var
  Auxiliar: string;
begin
  Auxiliar := EmptyStr;
  //Auxiliar := Chr(39);
  Auxiliar := Auxiliar + Copy(ADataStr,7,4);
  Auxiliar := Auxiliar + '.';
  Auxiliar := Auxiliar + Copy(ADataStr,4,2);
  Auxiliar := Auxiliar + '.';
  Auxiliar := Auxiliar + Copy(ADataStr,1,2);
  //Auxiliar := Auxiliar + Chr(39);
  if Controle = 'Inicio' then
    Auxiliar := Auxiliar + ' 00:00:01'
  else
    Auxiliar := Auxiliar + ' 23:59:59';
  Result:= Auxiliar;
end;

class procedure Tlibrary.AjustaForm(const AForm: TForm; ALayout: TLayout);
begin
    Aform.Parent := frmPrincipal;
    Aform.Height := Round(ALayout.Height);
    Aform.Width  := Round(ALayout.Width);
    Aform.Left   := Round(ALayout.Position.X);
    Aform.Top    := Round(ALayout.Position.Y) + 25;
    AForm.Show;
end;

class function Tlibrary.CalculaImpostos(const AAliquota,
  ABaseCalculo: double): double;
  begin
  result := 0;
  try
    result := ABaseCalculo * AAliquota / 100;
  except on E:Exception do
  begin
    result := 0;
  end;

  end;
end;

{class procedure Tlibrary.CarregaDados(const ATabela: string; const ADm: TdmRestDW;
  const AMemTable: TFDMemTable; const AParams: TDWParams);
var
  LErro     : string;
  LJSONValue: TJSONValue;
  LParams   : TDWParams;
begin
  LParams:= AParams;
  AMemTAble.Close;
  //AMemTable.Fields.Clear;
  ADm.DWClientEvents.SendEvent(ATabela, LParams, LErro);
  AMemTable.Open;
  try
    LJSONValue := TJSONValue.Create;
    LJSONValue.WriteToDataset(dtFull, APArams.ItemsString['result'].AsString, AMemTable);
    AMemTable.CommitUpdates;
  finally
    LJSONValue.DisposeOf;
    LJSONValue := nil;
  end;
end;}

{class procedure Tlibrary.CarregaDados(const ATabela: string;
  const ADm: TdmRestDW; const AMemTable : TFDMemTable);
var
  lDWParams : TDWParams;
  LErro     : string;
  LJSONValue: TJSONValue;
begin
try
  AMemTAble.Close;
  Adm.DWClientEvents.CreateDWParams(ATabela, LDWPArams);
  Adm.DWClientEvents.SendEvent(ATabela, LDWParams, LErro);
  AMemTable.Open;
  try
    LJSONValue := TJSONValue.Create;
    LJSONValue.WriteToDataset(dtFull, LDWPArams.ItemsString['result'].AsString, AMemTable);
    AMemTable.CommitUpdates;
  finally
    LJSONValue.DisposeOf;
    LJSONValue := nil;
  end;
except on E: Exception do
  begin
    ShowMessage('Erro ao carregar os dados: ' + 'Erro primário: ' + E.Message + '. Erro servidor: ' + LDWPArams.ItemsString['result'].AsString);
  end;
end;
end; }

{class function Tlibrary.CarregaPesquisa(const AEvento: string;
  const AMemTable: TFDMemTable): string;
var
  lDWParams : TDWParams;
  LErro     : string;
  LJSONValue: TJSONValue;
begin
  AMemTAble.Close;
  dmRestDW.DWClientEvents.CreateDWParams(AEvento, LDWPArams);
  dmRestDW.DWClientEvents.SendEvent(AEvento, LDWParams, LErro);

  AMemTable.Open;
  {DONE -oAndré -cEvetos RDW : Alterar as procedures que disparam eventos RDW para Functions que retornam se houve erro ou não (lErro = '' não houve erro)}
 { try
    if LErro = EmptyStr then
    begin
    LJSONValue := TJSONValue.Create;
    LJSONValue.WriteToDataset(dtFull, LDWPArams.ItemsString['result'].AsString, AMemTable);
    AMemTable.CommitUpdates;
    end;

    Result  := lErro;
  finally
    LJSONValue.DisposeOf;
    LJSONValue := nil;
  end;
end;  }

class function Tlibrary.ConcatenaInteiros(const AInteiro1, AInteiro2 : Word): integer;
var
  Aux1, Aux2 : string;
begin
  try
    Aux1    := IntToStr(AInteiro1);
    Aux2    := IntToStr(AInteiro2);
    Aux1    := Aux1 + Aux2;
    Result  := StrToInt(Aux1);
  except on E: Exception do
    Result  := 0;
  end;
end;

class procedure Tlibrary.MensagemEditVazio(var ACampo: TEdit);
begin
  ShowMessage('O campo ' + ACampo.TextPrompt + ' deve ser preenchido!');
  ACampo.SetFocus;
end;

class procedure Tlibrary.MensagemErroGravacao(const AErro: string);
begin
  ShowMessage('O seguinte erro ocorreu ao gravar: ' + AErro);
end;

class procedure Tlibrary.PreparaInsersao(const AMemTable: TFDMemTable);
begin
  if not AMemTable.Active then
    AMemTable.Open;
  AMemTable.Append;
  AMemTable.FieldByName('data_hora_inclusao').AsDateTime  := Now;
  AMemTable.FieldByName('status').AsBoolean               := True;
end;

{class function Tlibrary.EnviaParaBanco(const AOrigemDados: TRESTDWClientSQL): string;
var
  sErro : string;
begin
  result:= EmptyStr;
  //Envia os dados gravados localmente para o banco de dados e verifica se deu sucesso ou erro.
  if AOrigemDados.ApplyUpdates(sErro)
  then result := 'Gravado com sucesso!'
  else result := 'Erro ao enviar os dados para o banco de dados: ' + sErro;
end;}

class procedure Tlibrary.ExpandeMenu(const Menu : TListBox);
var
  x: byte;
begin
  //Expande todos os nodos
  //For x := 0 to Menu.Items.Count - 1 do
  //Menu.Items.i

//Recolhe todos os nodos
{procedure TForm1.Button2Click(Sender: TObject);
var
x: byte;
begin
For x := 0 to TreeView1.Items.Count - 1 do
TreeView1.Items.Item[x].Collapse(True);
end;}
end;

class function Tlibrary.FiltrarPelaId(const AMemTable: TFDMemTable;
  AId: string): Boolean;
begin
  AMemTable.Filtered := False;
  AMemTable.Filter   := 'id = ' + AId;
  AMemTable.Filtered := True;
  Result             := not AMemTable.Eof;
end;

class function Tlibrary.FiltrarPet(const AMemTable: TFDMemTable;
  AId: string; AIdCliente: string): Boolean;
begin
  AMemTable.Filtered := False;
  AMemTable.Filter   := 'id = ' + AId + 'and id_pessoa = ' + AIdCliente;
  AMemTable.Filtered := True;
  Result             := not AMemTable.Eof;
end;

{class procedure Tlibrary.GravarDados(const ATabela: string; const ADm: TdmRestDW;
  const AMemTable: TFDMemTable);
var
  LJSONValue  : TJSONValue;
  LDWParams   : TDWParams;
  LMsgErro    : string;
begin

try
  AMemTable.FetchAll;
  ADm.DWClientEvents.CreateDWParams('gravar', LDWParams);

  LDWParams.ItemsString['Tabela'].AsString  := ATabela;

  LJSONValue  := TJSONValue.Create;
  if not (AMemTable.IsEmpty) then
  begin
    //LJSONValue.Encoding := esUTF8;

    AMemTable.DisableControls;

    AMemTable.FilterChanges := [rtInserted];
    if not AMemTable.IsEmpty then
    begin
      LJSONValue.LoadFromDataset('dadosInsert', AMemTable, True);
      LDWParams.ItemsString['dadosInsert'].AsString := LJSONValue.ToJSON;
    end;

    AMemTable.FilterChanges := [rtModified];
    if not AMemTable.IsEmpty then
    begin
      LJSONValue.LoadFromDataset('dadosUpdate', AMemTable, True);
      LDWParams.ItemsString['dadosUpdate'].AsString := LJSONValue.ToJSON;
    end;

    ADm.DWClientEvents.SendEvent('gravar', LDWParams, LMsgErro);
  end;
finally
  LJSONValue.DisposeOf;
  LJSONValue  := nil;
  if AMemTable.UpdatesPending then
    AMemTable.CommitUpdates;
  AMemTable.EnableControls;
  AMemTable.FilterChanges := [rtInserted, rtModified, rtUnmodified];

end;

end;
}

class procedure Tlibrary.InsereBarra(ACampoEdit: TEdit; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if (ACampoEdit.Text.Length = 2) or (ACampoEdit.Text.Length = 5) then
  begin
    ACampoEdit.Text  := ACampoEdit.Text + '/';
    //edtAdmissao.SelStart := Length(edtAdmissao.Text) + 1;
    Key := 35;
    ACampoEdit.onKeyDown(nil, Key, KeyChar, Shift);
  end;
end;

{class function Tlibrary.GetDadosRelatorioGeral(const ALote: string; const ADataIni, ADataFim : TDate;
        const AEvento : string; const AMemTable : TFDMemTable) : string;
var
  LDWParams : TDWParams;
  LErro     : string;
  LJSONValue: TJSONValue;
begin
  AMemTAble.Close;
  dmRestDW.DWClientEvents.CreateDWParams(AEvento, LDWPArams);
  LDWParams.ItemsString['lote'].AsString          := ALote;
  LDWParams.ItemsString['data_inicial'].AsDate  := ADataIni;
  LDWParams.ItemsString['data_final'].AsDate    := ADataFim;
  dmRestDW.DWClientEvents.SendEvent(AEvento, LDWParams, LErro);
  AMemTable.Open;

  try
    if LErro = EmptyStr then
    begin
      LJSONValue := TJSONValue.Create;
      LJSONValue.WriteToDataset(dtFull, LDWPArams.ItemsString['result'].AsString, AMemTable);
      AMemTable.CommitUpdates;
    end;

    result  := LErro;
  finally
    LDWParams.Free;
    LJSONValue.DisposeOf;
    LJSONValue := nil;
  end;
end; }

{class procedure Tlibrary.GravaMemTable(const AMemTable: TFDMemTable);
begin
  AMemTable.UpdateRecord;
  AMemTable.Post;
end;

{class procedure Tlibrary.EntraEdit(obj: TObject);
begin
  if obj is TEdit then
    (obj as TEdit).StyleLookup := 'edtRazaoSocialStyle1';
end;}

class procedure Tlibrary.LerConfig;
var
  IniFile: TIniFile;
begin
try
  try
    IniFile:= TIniFile.Create(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'Config.ini'));
    FIP:= IniFile.ReadString('Conexao', 'IP', FIP);
    FPorta:= IniFile.ReadString('Conexao', 'Porta', FPorta);
  except on E:Exception do
  begin
    //
  end;

  end;
finally
  IniFile.DisposeOf;
end;
end;

class procedure Tlibrary.MarcaParaExclusao(const AMemTable: TFDMemTable);
{TODO -oAndré -cExclusões : Alterar essa classe para que outras tela possam usá-la.}
begin
  //Marca o registro como excluído
  AMemTable.Edit;
  AMemTable.FieldByName('data_hora_exclusao').AsDateTime  := Now;
  AMemTable.FieldByName('status').AsBoolean               := False;
  AMemTable.Post;
end;

class function Tlibrary.MascaraData(const AData: string): string;
var
  Aux : string;
begin
  Aux     := '';
  Aux     := Copy(AData, 1, 2);
  Aux     := Aux + '/';
  Aux     := Aux + Copy(AData, 3, 2);
  Aux     := Aux + '/';
  Aux     := Aux + Copy(AData, 5, 4);
  Result  := Aux;
end;

{class procedure Tlibrary.SaiEdit(const AEdit: TEdit);
begin
  AEdit.StyleLookup := '';
end; }

class procedure Tlibrary.SalvarConfg(const AIP: string; APorta: string);
var
  IniFile: TIniFile;
begin
try
  try
    IniFile:= TIniFile.Create(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'Config.ini'));
    IniFile.WriteString('Conexao', 'IP', AIP);
    IniFile.WriteString('Conexao', 'Porta', APorta);
  Except on E:Exception do
  begin
    //
  end;

  end;
finally
  IniFile.DisposeOf;
end;
end;

end.
