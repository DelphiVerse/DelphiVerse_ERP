unit srvIntellisof_ERP.service.Clientes;

interface

uses
  System.SysUtils, System.Classes, Server.providers.ProviderConnection,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.MySQL, FireDAC.Phys.MySQLDef,
  FireDAC.ConsoleUI.Wait, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client;

type
  TdmSrvConnect1 = class(TdmSrvConnect)
    qryCadastro: TFDQuery;
    qryClientes: TFDQuery;
    qryClientesid: TFDAutoIncField;
    qryClientesrazao_social: TStringField;
    qryClientesnome_fantasia: TStringField;
    qryClientescpf_cnpj: TStringField;
    qryClientesstatus: TStringField;
    qryCadastroid: TFDAutoIncField;
    qryCadastrorazao_social: TStringField;
    qryCadastronome_fantasia: TStringField;
    qryCadastrocpf_cnpj: TStringField;
    qryCadastrostatus: TStringField;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmSrvConnect1: TdmSrvConnect1;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

end.
