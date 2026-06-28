unit Gerencial.model.BaixasFinanceiras;

interface

uses
  System.SysUtils;

type
  TBaixasFinanceirasModel = class
  private
    FId: Int64;
    FLancamentoId: Int64;
    FContaBancariaId: Int64;
    FDataBaixa: TDateTime;
    FValorPago: Double;
    FValorJuros: Double;
    FValorMulta: Double;
    FValorDesconto: Double;
    FFormaPagamento: string;
    FCodigoTransacao: string;
    FObservacao: string;
    FDataCadastro: TDateTime;
    FUsuarioId: Int64;
  public
    property Id: Int64 read FId write FId;
    property LancamentoId: Int64 read FLancamentoId write FLancamentoId;
    property ContaBancariaId: Int64 read FContaBancariaId write FContaBancariaId;
    property DataBaixa: TDateTime read FDataBaixa write FDataBaixa;
    property ValorPago: Double read FValorPago write FValorPago;
    property ValorJuros: Double read FValorJuros write FValorJuros;
    property ValorMulta: Double read FValorMulta write FValorMulta;
    property ValorDesconto: Double read FValorDesconto write FValorDesconto;
    property FormaPagamento: string read FFormaPagamento write FFormaPagamento;
    property CodigoTransacao: string read FCodigoTransacao write FCodigoTransacao;
    property Observacao: string read FObservacao write FObservacao;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
    property UsuarioId: Int64 read FUsuarioId write FUsuarioId;

    constructor Create;
  end;

implementation

{ TBaixasFinanceirasModel }

constructor TBaixasFinanceirasModel.Create;
begin
  inherited;
  FId := 0;
  FLancamentoId := 0;
  FContaBancariaId := 0;
  FDataBaixa := Now;
  FValorPago := 0.00;
  FValorJuros := 0.00;
  FValorMulta := 0.00;
  FValorDesconto := 0.00;
  FFormaPagamento := 'PIX'; // Sugestão de default atual
  FCodigoTransacao := '';
  FObservacao := '';
  FDataCadastro := Now;
  FUsuarioId := 0;
end;

end.
