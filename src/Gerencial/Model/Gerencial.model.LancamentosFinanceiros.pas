unit Gerencial.model.LancamentosFinanceiros;

interface

uses
  System.SysUtils;

type
  TLancamentosModel = class
  private
    FId: Integer;
    FTipoLancamento: string; // 'PAGAR' ou 'RECEBER'
    FPessoaId: Integer;
    FPlanoContaId: Integer;
    FCentroCustoId: Int64; // Permite 0 / nulo no banco
    FDescricao: string;
    FNumeroDocumento: string;
    FDataEmissao: TDateTime;
    FDataVencimento: TDateTime;
    FDataPagamento: TDateTime;
    FValorOriginal: Double;
    FValorJurosMulta: Double;
    FValorDesconto: Double;
    FValorPago: Double;
    FStatus: string; // 'A', 'B', 'P', 'C'
    FDataCadastro: TDateTime;
    FDataAlteracao: TDateTime;

    // Propriedades Virtuais de Join para facilitar as Views FMX
    FPessoaNome: string;
    FPlanoContaNome: string;
    FCentroCustoNome: string;
  public
    property Id: Integer read FId write FId;
    property TipoLancamento: string read FTipoLancamento write FTipoLancamento;
    property PessoaId: Integer read FPessoaId write FPessoaId;
    property PlanoContaId: Integer read FPlanoContaId write FPlanoContaId;
    property CentroCustoId: Int64 read FCentroCustoId write FCentroCustoId;
    property Descricao: string read FDescricao write FDescricao;
    property NumeroDocumento: string read FNumeroDocumento write FNumeroDocumento;
    property DataEmissao: TDateTime read FDataEmissao write FDataEmissao;
    property DataVencimento: TDateTime read FDataVencimento write FDataVencimento;
    property DataPagamento: TDateTime read FDataPagamento write FDataPagamento;
    property ValorOriginal: Double read FValorOriginal write FValorOriginal;
    property ValorJurosMulta: Double read FValorJurosMulta write FValorJurosMulta;
    property ValorDesconto: Double read FValorDesconto write FValorDesconto;
    property ValorPago: Double read FValorPago write FValorPago;
    property Status: string read FStatus write FStatus;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
    property DataAlteracao: TDateTime read FDataAlteracao write FDataAlteracao;

    // Joins
    property PessoaNome: string read FPessoaNome write FPessoaNome;
    property PlanoContaNome: string read FPlanoContaNome write FPlanoContaNome;
    property CentroCustoNome: string read FCentroCustoNome write FCentroCustoNome;

    constructor Create;
  end;

implementation

{ TLancamentosModel }

constructor TLancamentosModel.Create;
begin
  inherited;
  FId := 0;
  FTipoLancamento := 'CRÉDITO';
  FPessoaId := 0;
  FPlanoContaId := 0;
  FCentroCustoId := 0;
  FDescricao := '';
  FNumeroDocumento := '0';
  FDataEmissao := Now;
  FDataVencimento := Now;
  FDataPagamento := 0; // Data zerada / sem pagamento inicial
  FValorOriginal := 0.00;
  FValorJurosMulta := 0.00;
  FValorDesconto := 0.00;
  FValorPago := 0.00;
  FStatus := 'A';
  FDataCadastro := Now;
end;

end.
