unit Gerencial.model.Clientes;

interface

uses
  System.SysUtils;

type
  TClienteModel = class
  private
    FId: Integer;
    FRazaoSocial: string;
    FNomeFantasia: string;
    FCpfCnpj: string;
    FRgIe: string;
    FStatus: string;
    FEmail: string;
    FTelefone: string;
    FCep: string;
    FEndereco: string;
    FNumero: string;
    FComplemento: string;
    FBairro: string;
    FCidade: string;
    FUf: string;
    FDataCadastro: TDateTime;
    FObservacoes: string;
    FTipoPessoa: Integer;
  public
    property Id: Integer read FId write FId;
    property RazaoSocial: string read FRazaoSocial write FRazaoSocial;
    property NomeFantasia: string read FNomeFantasia write FNomeFantasia;
    property CpfCnpj: string read FCpfCnpj write FCpfCnpj;
    property RgIe: string read FRgIe write FRgIe;
    property Status: string read FStatus write FStatus;
    property Email: string read FEmail write FEmail;
    property Telefone: string read FTelefone write FTelefone;
    property Cep: string read FCep write FCep;
    property Endereco: string read FEndereco write FEndereco;
    property Numero: string read FNumero write FNumero;
    property Complemento: string read FComplemento write FComplemento;
    property Bairro: string read FBairro write FBairro;
    property Cidade: string read FCidade write FCidade;
    property Uf: string read FUf write FUf;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
    property Observacoes: string read FObservacoes write FObservacoes;
    property TipoPessoa: Integer read FTipoPessoa write FTipoPessoa;

    constructor Create;
  end;

implementation

constructor TClienteModel.Create;
begin
  FStatus := 'A';
  FDataCadastro := Now;
end;

end.
