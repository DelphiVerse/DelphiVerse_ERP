unit Gerencial.model.Planos;

interface

uses
  System.SysUtils;

type
  TPlanoModel = class
  private
    FId: Integer;
    FNome: string;
    FDescricao: string;
    FValorBase: Double;
    FLimiteUsuarios: Integer;
    FStatus: string;
    FDataCadastro: TDateTime;
  public
    property Id: Integer read FId write FId;
    property Nome: string read FNome write FNome;
    property Descricao: string read FDescricao write FDescricao;
    property ValorBase: Double read FValorBase write FValorBase;
    property LimiteUsuarios: Integer read FLimiteUsuarios write FLimiteUsuarios;
    property Status: string read FStatus write FStatus;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;

    constructor Create;
  end;

implementation

{ TPlanoModel }

constructor TPlanoModel.Create;
begin
  inherited;
  FId := 0;
  FNome := '';
  FDescricao := '';
  FValorBase := 0.00;
  FLimiteUsuarios := 1;
  FStatus := 'ATIVO';
  FDataCadastro := Now;
end;

end.
