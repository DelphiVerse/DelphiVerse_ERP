unit Gerencial.model.CentroCustos;

interface

uses
  System.SysUtils;

type
  TCentroCustosModel = class
  private
    FId: Int64;
    FNome: string;
    FStatus: string; // 'A' ou 'I'
    FDataCadastro: TDateTime;
  public
    property Id: Int64 read FId write FId;
    property Nome: string read FNome write FNome;
    property Status: string read FStatus write FStatus;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;

    constructor Create;
  end;

implementation

{ TCentroCustosModel }

constructor TCentroCustosModel.Create;
begin
  inherited;
  FId := 0;
  FNome := '';
  FStatus := 'A';
  FDataCadastro := Now;
end;

end.
