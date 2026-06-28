unit Gerencial.utils.Validacoes;

interface

uses
  System.SysUtils,
  System.UITypes,
  FMX.Dialogs,
  // Units do ACBr (certifique-se de que o ACBr está no seu Library Path)
  ACBrValidador;

type
  TValidacao = class
  private
    { Private declarations }
  public
    /// <summary>
    ///  Valida CPF ou CNPJ usando o componente ACBrValidador
    /// </summary>
    class function DocumentoEhValido(const ADocumento: string): Boolean;

    /// <summary>
    ///  Valida se uma string é um e-mail válido
    /// </summary>
    class function EmailEhValido(const AEmail: string): Boolean;

    /// <summary>
    ///  Exemplo de validação de campo obrigatório
    /// </summary>
    class function CampoPreenchido(const ATexto: string; const ANomeCampo: string): Boolean;
  end;

implementation

{ TValidacao }

class function TValidacao.DocumentoEhValido(const ADocumento: string): Boolean;
var
  vACBrValidador: TACBrValidador;
  vLimpo: string;
begin
  Result := False;
  vLimpo := StringReplace(StringReplace(StringReplace(ADocumento, '.', '', [rfReplaceAll]), '-', '', [rfReplaceAll]), '/', '', [rfReplaceAll]);

  if vLimpo.Trim.IsEmpty then
    Exit;

  vACBrValidador := TACBrValidador.Create(nil);
  try
    vACBrValidador.Documento := vLimpo;

    // O ACBr identifica automaticamente se é CPF ou CNPJ pelo tamanho da string
    if Length(vLimpo) <= 11 then
      vACBrValidador.TipoDocto := docCPF
    else
      vACBrValidador.TipoDocto := docCNPJ;

    Result := vACBrValidador.Validar;
  finally
    vACBrValidador.Free;
  end;
end;

class function TValidacao.EmailEhValido(const AEmail: string): Boolean;
var
  vACBrValidador: TACBrValidador;
begin
  vACBrValidador := TACBrValidador.Create(nil);
  try
    vACBrValidador.Documento := AEmail;
    vACBrValidador.TipoDocto := docEmail;
    Result := vACBrValidador.Validar;
  finally
    vACBrValidador.Free;
  end;
end;

class function TValidacao.CampoPreenchido(const ATexto: string; const ANomeCampo: string): Boolean;
begin
  Result := not ATexto.Trim.IsEmpty;
  if not Result then
    ShowMessage('O campo ' + ANomeCampo + ' é obrigatório.');
end;

end.
