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
  IniFiles;

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
  FLockLog: TObject;
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
    IniFile.Free;
  end;
end;

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
  IniFile.Free;
end;
end;

end.
