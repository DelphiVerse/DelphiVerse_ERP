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
  System.TypInfo,

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
  Fmx.DateTimeCtrls,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Memo,
  FMX.ExtCtrls,

  IniFiles,
  untConstantes;

type
  Tlibrary = class
    private
       class var
         FIP, FPorta: string;
    public
      {Varáveis}

      {Métodos}
      class procedure LerConfig;
      class procedure SalvarConfg(const AIP: string; APorta: string);
      class procedure AbrirForm(const AFormClass: TComponentClass);
      class function AjustaDataSql(const ADataStr, Controle : string) : string;
      class function CalculaImpostos(const AAliquota, ABaseCalculo : double) : double;
      class function MascaraData(const AData : string) : string;
      class procedure InsereBarra(ACampoEdit : TEdit; var Key: Word; var KeyChar: Char; Shift: TShiftState);
      class procedure MensagemEditVazio(var ACampo : TEdit);
      class procedure PreparaInsersao(const AMemTable : TFDMemTable);
      class function ConcatenaInteiros(const AInteiro1, AInteiro2 : Word): integer;
      class procedure MensagemErroGravacao(const AErro: string);
      class function FiltrarPelaId(const AMemTable: TFDMemTable; AId: string): Boolean;
      class function FiltrarPet(const AMemTable: TFDMemTable; AId: string; AIdCliente: string): Boolean;
      class procedure ModelParaTela(AModel: TObject; AContainer: TControl; AInteiro: Boolean = True); static;
      class procedure TelaParaModel(AModel: TObject; AContainer: TControl; AInteiro: Boolean = True); static;
      class procedure MensagemCampoVazio(const ANomeCampo: string); static;
      class procedure AjustaPosicaoBotoes(AContainer: TRectangle); static;
      class procedure LimparTodosOsCampos(ALayout: TLayout); static;
      class procedure GravarLog(const AMensagem: string); static;
      {Propriedades}
      class property IP : string read FIP write FIP;
      class property Porta : string read FPorta write FPorta;
  end;

implementation

{ TLibrary }

class procedure Tlibrary.GravarLog(const AMensagem: string);
var
  LArquivoLog: TextFile;
  LCaminhoDir, LNomeArquivo: string;
//  FLockLog: TObject;
begin
  // Define o diretório raiz do executável
  LCaminhoDir := ExtractFilePath(ParamStr(0)) + 'Logs\';

  // Cria a pasta Logs se não existir
  if not DirectoryExists(LCaminhoDir) then
    ForceDirectories(LCaminhoDir);

  // Nome do arquivo baseado na data atual (Ex: Log_2024-05-20.txt)
  LNomeArquivo := LCaminhoDir + 'Log_' + FormatDateTime('yyyy-mm-dd', Now) + '.txt';

  // O uso de TMonitor.Enter garante que se duas requisições Horse tentarem
  // gravar ao mesmo tempo, uma aguardará a outra terminar (Thread Safe)
//  TMonitor.Enter(HInstance);
  try
    AssignFile(LArquivoLog, LNomeArquivo);
    try
      if FileExists(LNomeArquivo) then
        Append(LArquivoLog) // Abre para adicionar ao fim
      else
        Rewrite(LArquivoLog); // Cria o arquivo novo

      // Grava a linha: [HH:MM:SS] Mensagem
      Writeln(LArquivoLog, FormatDateTime('[hh:nn:ss] ', Now) + AMensagem);
    finally
      CloseFile(LArquivoLog);
    end;
  finally
//    TMonitor.Exit(HInstance);
  end;
end;

class procedure Tlibrary.ModelParaTela(AModel: TObject; AContainer: TControl; AInteiro: Boolean = True);
var
  Context: TRttiContext;
  Tipo: TRttiType;
  Prop: TRttiProperty;
  Comp: TFmxObject;
  NomeProp: string;
  LTextProcurado: string;
  I: Integer;
begin
  Context := TRttiContext.Create;
  try
    Tipo := Context.GetType(AModel.ClassType);

    for Comp in AContainer.Children do
    begin
      // 1. Verificamos se o componente tem um nome e se segue o padrão 'xxxNomePropriedade'
      if (Length(Comp.Name) < 4) then
        Continue;

      NomeProp := Copy(Comp.Name, 4, MaxInt);
      Prop := Tipo.GetProperty(NomeProp);

      // 2. Só prosseguimos se a propriedade existir na Model
      if Assigned(Prop) then
      begin
        // --- Tratamento para TEdit ---
        if (Comp is TEdit) then
        begin
          TEdit(Comp).Text := Prop.GetValue(AModel).ToString;
        end
        // 2. Tratamento para TDateEdit (Data de Cadastro)
        else if (Comp is TDateEdit) then
        begin
          var LData := Prop.GetValue(AModel).AsType<TDateTime>;
          if LData > 0 then
          begin
            TDateEdit(Comp).Date := LData;
            TDateEdit(Comp).IsEmpty := False;
          end
          else
          begin
            TDateEdit(Comp).Date := 0;
            TDateEdit(Comp).IsEmpty := True; // Diz ao FMX para deixar o campo em branco visualmente
            TDateEdit(Comp).Text := '';
          end;
         end

        // --- Tratamento para TComboBox (Corrigido para FMX) ---
        else if (Comp is TComboBox) then
        begin
          if AInteiro then
            TComboBox(Comp).ItemIndex := Prop.GetValue(AModel).AsInteger
          else
          begin
            // 1. Captura o texto que está gravado na Model
            LTextProcurado := Prop.GetValue(AModel).AsString;

            // 2. Reseta a seleção padrão caso não encontre
            TComboBox(Comp).ItemIndex := -1;

            // 3. Varre os itens do Combo procurando o match perfeito de texto
            for I := 0 to TComboBox(Comp).Items.Count - 1 do
            begin
              // Usamos o ToUpper para garantir o match mesmo se houver divergência de caixa
              if TComboBox(Comp).Items[I].ToUpper = LTextProcurado.ToUpper then
              begin
                TComboBox(Comp).ItemIndex := I;
                Break; // Achou, para o laço imediatamente
              end;
            end;
          end;
        end

        // --- Tratamento para //TPopupBox (Corrigido para FMX) ---
        else if (Comp is TPopupBox) then
        begin
          if AInteiro then
            TPopupBox(Comp).ItemIndex := Prop.GetValue(AModel).AsInteger
          else
          begin
            // 1. Captura o texto que está gravado na Model
            LTextProcurado := Prop.GetValue(AModel).AsString;

            // 2. Reseta a seleção padrão caso não encontre
            TPopupBox(Comp).ItemIndex := -1;

            // 3. Varre os itens do Combo procurando o match perfeito de texto
            for I := 0 to TPopupBox(Comp).Items.Count - 1 do
            begin
              // Usamos o ToUpper para garantir o match mesmo se houver divergência de caixa
              if TPopupBox(Comp).Items[I].ToUpper = LTextProcurado.ToUpper then
              begin
                TPopupBox(Comp).ItemIndex := I;
                Break; // Achou, para o laço imediatamente
              end;
            end;
          end;
        end

        // --- Tratamento para TSwitch ---
        else if (Comp is TSwitch) then
        begin
          // Tratamento genérico atendendo tanto 'A' (Ativo) quanto 'ATIVO'
          TSwitch(Comp).IsChecked := (Prop.GetValue(AModel).ToString.ToUpper = 'A') or
                                     (Prop.GetValue(AModel).ToString.ToUpper = 'ATIVO');
        end;
      end;
    end;
  finally
    Context.Free;
  end;
end;

class procedure Tlibrary.TelaParaModel(AModel: TObject; AContainer: TControl; AInteiro: Boolean = True);
var
  Context: TRttiContext;
  Tipo: TRttiType;
  Prop: TRttiProperty;
  Comp: TFmxObject;
  NomeProp: string;
  Valor: TValue;
begin
  Context := TRttiContext.Create;
  Tipo := Context.GetType(AModel.ClassType);

  // Percorre todos os filhos do container (TLayout)
  for Comp in AContainer.Children do
  begin
    // Padronizamos o nome: 3 letras de prefixo + Nome da Propriedade (ex: swtStatus)
    NomeProp := Copy(Comp.Name, 4, MaxInt);
    Prop := Tipo.GetProperty(NomeProp);

    if Assigned(Prop) and Prop.IsWritable then
    begin
      if (Comp is TEdit) then // 1. Tratamento para TEdit (Texto e Números)
      begin
        case Prop.PropertyType.TypeKind of
          tkInteger, tkInt64: Valor := StrToIntDef(TEdit(Comp).Text, 0);
          tkFloat: Valor := StrToFloatDef(TEdit(Comp).Text, 0);
        else
          Valor := TEdit(Comp).Text;
        end;
      end
      else if (Comp is TDateEdit) then // 2. Tratamento para TDateEdit (Data de Cadastro)
        Valor := TDateEdit(Comp).Date
      else if (Comp is TSwitch) then // 3. Tratamento para TCheckBox ou TSwitch (Status 'A' ou 'I')
      begin
        if TSwitch(Comp).IsChecked then Valor := 'A' else Valor := 'I';
      end
      else if (Comp is TComboBox) then // 4. Tratamento para TComboBox (Índice ou Texto)
      begin
        if AInteiro then
          Valor := TValue.From<Integer>(TComboBox(Comp).ItemIndex)
        else
          Valor := TValue.From<string>(TComboBox(Comp).Text);
        Prop.SetValue(AModel, Valor);
      end
      else if (Comp is TLabel) then
        Continue
      else if (Comp is TPopupBox) then // 5. Tratamento para TPopupBox (Índice ou Texto)
      begin
        if AInteiro then
          Valor := TValue.From<Integer>(TPopupBox(Comp).ItemIndex)
        else
          Valor := TValue.From<string>(TPopupBox(Comp).Text);
        Prop.SetValue(AModel, Valor);
      end;

      if not Valor.IsEmpty then // Aplica o valor na propriedade da Model se foi identificado
        Prop.SetValue(AModel, Valor);
    end;
  end;
end;

class procedure Tlibrary.MensagemCampoVazio(const ANomeCampo: string);
begin
  ShowMessage(Format(_MENSAGEM_CAMPO_VAZIO, [ANomeCampo]));
end;

class procedure Tlibrary.AbrirForm(const AFormClass: TComponentClass);
var FActiveForm: TForm;
begin
  if (assigned(FActiveForm)) then
  begin
    Application.CreateForm(AFormClass, FActiveForm);

  end;
end;

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

class procedure Tlibrary.AjustaPosicaoBotoes(AContainer: TRectangle);
var
  I, LCount: Integer;
  LMargemInterna: Single;
  LControl: TControl;
begin
  // Conta quantos controles (botões) existem no layout
  LCount := AContainer.ControlsCount;

  if LCount = 0 then Exit;

  // Calcula a largura que cada botão deve ter
  // Subtrai as margens para que os botões não fiquem colados
  LMargemInterna := ((AContainer.Width - 400) / LCount);

  for I := 0 to LCount - 1 do
  begin
    if AContainer.Controls[I] is TControl then
    begin
      LControl := TControl(AContainer.Controls[I]);

      // Define o alinhamento como Left para que fiquem em linha
      LControl.Align  := TAlignLayout.Left;

//      LControl.Position.X:= 3;

      // Aplica margens laterais para criar o espaçamento igual
      LControl.Margins.Left  := LMargemInterna;
      LControl.Margins.Right := 5;
    end;
  end;
end;

class function Tlibrary.CalculaImpostos(const AAliquota,
  ABaseCalculo: double): double;
begin
  try
    result := ABaseCalculo * AAliquota / 100;
  except on E:Exception do
  begin
    result := 0;
  end;

  end;
end;

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
  ShowMessage(Format(_MENSAGEM_CAMPO_VAZIO, [ACampo.TextPrompt]));
  ACampo.SetFocus;
end;

class procedure Tlibrary.MensagemErroGravacao(const AErro: string);
begin
  ShowMessage(Format(_MENSAGEM_FALHA_GRAVACAO, [AErro]));
end;

class procedure Tlibrary.PreparaInsersao(const AMemTable: TFDMemTable);
begin
  if not AMemTable.Active then
    AMemTable.Open;
  AMemTable.Append;
  AMemTable.FieldByName('data_hora_inclusao').AsDateTime  := Now;
  AMemTable.FieldByName('status').AsBoolean               := True;
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

class procedure Tlibrary.LerConfig;
var
  IniFile: TIniFile;
begin
  IniFile:= TIniFile.Create(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'Config.ini'));
  try
    try
      FIP:= IniFile.ReadString('Conexao', 'IP', FIP);
      FPorta:= IniFile.ReadString('Conexao', 'Porta', FPorta);
    except on E:Exception do
    begin
      //
    end;

    end;
  finally
    IniFile.Free;
  end;
end;

class procedure Tlibrary.LimparTodosOsCampos(ALayout: TLayout);
var
  I: Integer;
  LControl: IControl;
begin
  for I := 0 to ALayout.ControlsCount - 1 do
  begin
    LControl := ALayout.Controls[I];

    if LControl is TEdit then
    begin
      TEdit(LControl).Text := '';
    end
    else if LControl is TDateEdit then
    begin
      TDateEdit(LControl).Text := '';
    end
    else if LControl is TMemo then
    begin
      TMemo(LControl).Text := '';
    end
    else if LControl is TComboBox then
    begin
      TComboBox(LControl).ItemIndex := -1;
    end
    else if LControl is TPopupBox then
    begin
      TPopupBox(LControl).ItemIndex := -1;
    end
    else if LControl is TSwitch then
    begin
      TSwitch(LControl).IsChecked := False;
    end
    else if LControl is TDateEdit then
    begin
      TDateEdit(LControl).Date := Now;
    end
    else if LControl is TLayout then
    begin
      LimparTodosOsCampos(TLayout(LControl));
    end;
  end;
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

class procedure Tlibrary.SalvarConfg(const AIP: string; APorta: string);
var
  IniFile: TIniFile;
begin
  IniFile:= TIniFile.Create(System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'Config.ini'));
  try
    try
      IniFile.WriteString('Conexao', 'IP', AIP);
      IniFile.WriteString('Conexao', 'Porta', APorta);
    Except on E:Exception do
    begin
      //
    end;

    end;
  finally
    IniFile.Free;
  end;
end;

end.
