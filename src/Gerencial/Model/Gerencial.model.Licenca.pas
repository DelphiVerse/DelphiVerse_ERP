unit Gerencial.model.Licenca;

interface

uses
  System.SysUtils;

type
  TLicencaModel = class
  private
    FId: Integer;
    FClienteId: Integer;
    FPlanoId: Integer;
    FModuloId: Integer; // Aceita 0 ou Nulo se não houver vertical escolhida
    FDataInicio: TDateTime;
    FDataVencimento: TDateTime;
    FValorTotal: Double; // Plano Base + Módulo (se hover)
    FChaveAtivacao: string;
    FStatus: string;
    FDataCadastro: TDateTime;

    // Propriedades virtuais de Join trazidas pela API para popular o TListView
    FClienteNome: string;
    FPlanoNome: string;
    FModuloNome: string;
  public
    property Id: Integer read FId write FId;
    property ClienteId: Integer read FClienteId write FClienteId;
    property PlanoId: Integer read FPlanoId write FPlanoId;
    property ModuloId: Integer read FModuloId write FModuloId;
    property DataInicio: TDateTime read FDataInicio write FDataInicio;
    property DataVencimento: TDateTime read FDataVencimento write FDataVencimento;
    property ValorTotal: Double read FValorTotal write FValorTotal;
    property ChaveAtivacao: string read FChaveAtivacao write FChaveAtivacao;
    property Status: string read FStatus write FStatus;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;

    // Propriedades dos Joins
    property ClienteNome: string read FClienteNome write FClienteNome;
    property PlanoNome: string read FPlanoNome write FPlanoNome;
    property ModuloNome: string read FModuloNome write FModuloNome;

    constructor Create;
  end;

implementation

{ TLicencaModel }

constructor TLicencaModel.Create;
begin
  inherited;
  FId := 0;
  FClienteId := 0;
  FPlanoId := 0;
  FModuloId := 0; // Inicializa em zero (Sem Módulo / Geral)
  FDataInicio := Now;
  FDataVencimento := IncMonth(Now, 1);
  FValorTotal := 0.00;
  FChaveAtivacao := '';
  FStatus := 'ATIVO';
  FDataCadastro := Now;
end;

end.
