unit Gerencial.model.Modulos;

interface

uses
  System.SysUtils;

type
  TModuloModel = class
  private
    FId: Integer;
    FNome: string;
    FChaveIdentificadora: string;
    FDescricao: string;
    FValorAdicional: Double;
    FStatus: string;
    FDataCadastro: TDateTime;
  public
    property Id: Integer read FId write FId;
    property Nome: string read FNome write FNome;
    property ChaveIdentificadora: string read FChaveIdentificadora write FChaveIdentificadora;
    property Descricao: string read FDescricao write FDescricao;
    property ValorAdicional: Double read FValorAdicional write FValorAdicional;
    property Status: string read FStatus write FStatus;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;

    constructor Create;
  end;

implementation

{ TModuloModel }

constructor TModuloModel.Create;
begin
  inherited;
  FStatus := 'A';
  FDataCadastro := Now;
  FValorAdicional := 0.00;
end;

end.
