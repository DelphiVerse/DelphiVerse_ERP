unit srvIntellisof_GIL.service.Clientes;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,

  ServerGIL.providers.ProviderConnection,

  DataSet.Serialize,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.ConsoleUI.Wait,
  FireDAC.Phys.MySQLDef,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Phys.MySQL;

type
  TdmGILConnectClientes = class(TdmGILConnect)
    qryCadastro: TFDQuery;
    qryCadastroid: TFDAutoIncField;
    qryCadastrorazao_social: TStringField;
    qryCadastronome_fantasia: TStringField;
    qryCadastrocpf_cnpj: TStringField;
    qryCadastrorg_ie: TStringField;
    qryCadastrostatus: TStringField;
    qryCadastrodata_cadastro: TDateTimeField;
    qryCadastroobservacoes: TMemoField;
    qryCadastrotelefone: TStringField;
    qryCadastroemail: TStringField;
    qryCadastrocep: TStringField;
    qryCadastroendereco: TStringField;
    qryCadastronumero: TStringField;
    qryCadastrocomplemento: TStringField;
    qryCadastrobairro: TStringField;
    qryCadastrocidade: TStringField;
    qryCadastrouf: TStringField;
    qryCadastrotipo_pessoa: TIntegerField;
    qryERP: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    FQuery: TFDQuery;
    function SincronizarTenantERP(const AClienteId: Int64; const ARazaoSocial,
      ACnpj: string): Boolean;
    { Private declarations }
  public
    { Public declarations }
    function ListarTodos: TFDQuery;
    function ListarPorId(const AId: Int64): TFDQuery;
    function Inserir(const AJson: TJSONObject): Boolean;
    function Atualizar(const AId: Int64; const AJson: TJSONObject): Boolean;
    function Deletar(const AId: Int64): Boolean;
  end;

var
  dmGILConnectClientes: TdmGILConnectClientes;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TdmGILConnectClientes }

function TdmGILConnectClientes.Atualizar(const AId: Int64;
  const AJson: TJSONObject): Boolean;
begin
//  ListarPorId(AId);
  qryCadastro.Close;
  qryCadastro.SQL.Add(' WHERE id = :id');
  qryCadastro.ParamByName('id').AsLargeInt := AId;
  qryCadastro.Open;
  if not qryCadastro.IsEmpty then
  begin
    qryCadastro.MergeFromJSONObject(AJson, False);
    Result := qryCadastro.ApplyUpdates(0) = 0;
  end;
end;

function TdmGILConnectClientes.SincronizarTenantERP(const AClienteId: Int64;
  const ARazaoSocial, ACnpj: string): Boolean;
begin
  Result := False;

  conConnectERP.StartTransaction;
  try
    qryERP.Close;
    qryERP.SQL.Text := 'SELECT * FROM tenants WHERE 1 <> 1';
    qryERP.Open;

    qryERP.Append;
    // Mapeamento dos campos baseado no que foi enviado pelo GIL
    // Ajuste os nomes dos campos da tabela 'tenants' conforme sua modelagem real do MySQL
    qryERP.FieldByName('id').AsLargeInt           := AClienteId; // Usando o ID do GIL para manter o vínculo unificado
    qryERP.FieldByName('razao_social').AsString   := ARazaoSocial;
    qryERP.FieldByName('nome_fantasia').AsString  := ARazaoSocial;
    qryERP.FieldByName('cnpj').AsString           := ACnpj;
    qryERP.FieldByName('status').AsString         := 'A';
    qryERP.FieldByName('data_criacao').AsDateTime := Now;
    qryERP.Post;

    if qryERP.ApplyUpdates(0) = 0 then
    begin
      conConnectERP.Commit;
      Result := True;
    end
    else
    begin
      conConnectERP.Rollback;
    end;
  except
    conConnectERP.Rollback;
    raise;
  end;
end;

procedure TdmGILConnectClientes.DataModuleCreate(Sender: TObject);
begin
  inherited;
  if Assigned(qryERP) then
    qryERP.Connection := conConnectERP;
end;

function TdmGILConnectClientes.Deletar(const AId: Int64): Boolean;
begin
  ListarPorId(AId);
  if not qryAux.IsEmpty then
  begin
    qryAux.Delete;
    Result := qryAux.ApplyUpdates(0) = 0;
  end;
end;

function TdmGILConnectClientes.Inserir(const AJson: TJSONObject): Boolean;
var
  lClienteId: Int64;
  lRazaoSocial,
  lCNPJ: string;
begin
  Result:= False;

  conConnectGIL.StartTransaction;
  try
    if qryCadastro.State = dsInactive then
      qryCadastro.Open;

    qryCadastro.LoadFromJSON(AJson, False);
    if qryCadastro.ApplyUpdates(0) = 0 then
    begin
      qryCadastro.CommitUpdates;
      lClienteId  := qryCadastroid.AsInteger;
      lRazaoSocial:= qryCadastrorazao_social.AsString;
      lCNPJ       := qryCadastrocpf_cnpj.AsString;
      if SincronizarTenantERP(lClienteId, lRazaoSocial, lCNPJ) then
      begin
        conConnectGIL.Commit;
        Result := True;
      end
      else
      begin
        conConnectGIL.Rollback;
      end;
    end;
  except
    conConnectGIL.Rollback;
    raise;
  end;
end;

function TdmGILConnectClientes.ListarPorId(const AId: Int64): TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM clientes WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;
  Result := qryAux;
end;

function TdmGILConnectClientes.ListarTodos: TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM clientes ORDER BY razao_social';
  qryAux.Open;
  qryAux.First;
  Result := qryAux;
end;

end.
