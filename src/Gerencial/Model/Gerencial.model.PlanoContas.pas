unit Gerencial.model.PlanoContas;

interface

uses
  System.SysUtils;

type
  TPlanoContasModel = class
  private
    FId: Int64;
    FCodigoContabil: string;
    FNome: string;
    FTipo: string; // 'RECEITA' ou 'DESPESA'
    FStatus: string; // 'A' ou 'I'
    FDataCadastro: TDateTime;
  public
    property Id: Int64 read FId write FId;
    property CodigoContabil: string read FCodigoContabil write FCodigoContabil;
    property Nome: string read FNome write FNome;
    property Tipo: string read FTipo write FTipo;
    property Status: string read FStatus write FStatus;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;

    constructor Create;
  end;

implementation

{ TPlanoContasModel }

constructor TPlanoContasModel.Create;
begin
  inherited;
  FId := 0;
  FCodigoContabil := '';
  FNome := '';
  FTipo := 'RECEITA';
  FStatus := 'A';
  FDataCadastro := Now;
end;

end.
