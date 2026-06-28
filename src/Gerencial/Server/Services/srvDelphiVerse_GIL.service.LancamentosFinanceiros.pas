unit srvDelphiVerse_GIL.service.LancamentosFinanceiros;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,

  ServerGIL.providers.ProviderConnection,

  Data.DB,

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
  FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef,
  FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client;

type
  TdmGILConnectLancFinanceiros = class(TdmGILConnect)
  private
    { Private declarations }
  public
    { Public declarations }
    function ListarTodas: TFDQuery;
    function ListarPorId(const AId: Int64): TFDQuery;
    function Inserir(const AJson: TJSONObject): Boolean;
    function Atualizar(const AId: Int64; const AJson: TJSONObject): Boolean;
    function Deletar(const AId: Int64): Boolean;
  end;

var
  dmGILConnectLancFinanceiros: TdmGILConnectLancFinanceiros;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TdmGILConnectLancFinanceiros }

function TdmGILConnectLancFinanceiros.Atualizar(const AId: Int64;
  const AJson: TJSONObject): Boolean;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM lancamentos_financeiros WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;

  // Tratamento de Integridade do FireDAC
  qryAux.UpdateOptions.UpdateTableName := 'lancamentos_financeiros';
  qryAux.UpdateOptions.KeyFields := 'id';
  qryAux.UpdateOptions.RefreshMode := rmManual;
  qryAux.UpdateOptions.CountUpdatedRecords := False;
  qryAux.CachedUpdates:= True;
  qryAux.Open;
  if not qryAux.IsEmpty then
  begin
    qryAux.MergeFromJSONObject(AJson, False);
    Result := qryAux.ApplyUpdates(0) = 0;
  end
  else
    Result := False;
end;

function TdmGILConnectLancFinanceiros.Deletar(const AId: Int64): Boolean;
begin
  Result:= False;
  ListarPorId(AId);
  if not qryAux.IsEmpty then
  begin
    qryAux.Delete;
    Result := qryAux.ApplyUpdates(0) = 0;
  end;
end;

function TdmGILConnectLancFinanceiros.Inserir(
  const AJson: TJSONObject): Boolean;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM lancamentos_financeiros WHERE 1 <> 1';

  // Tratamento de Integridade do FireDAC
  qryAux.UpdateOptions.UpdateTableName := 'lancamentos_financeiros';
  qryAux.UpdateOptions.KeyFields := 'id';
  qryAux.UpdateOptions.RefreshMode := rmManual;
  qryAux.UpdateOptions.CountUpdatedRecords := False;
  qryAux.CachedUpdates:= True;
  qryAux.Open;
  qryAux.LoadFromJSON(AJson, False);
  Result := qryAux.ApplyUpdates(0) = 0;
end;

function TdmGILConnectLancFinanceiros.ListarPorId(const AId: Int64): TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM lancamentos_financeiros WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;
  Result := qryAux;
end;

function TdmGILConnectLancFinanceiros.ListarTodas: TFDQuery;
begin
  qryAux.Close;
  // Ordena pelos vencimentos mais próximos
  qryAux.SQL.Text := 'SELECT * FROM lancamentos_financeiros ORDER BY data_vencimento ASC';
  qryAux.Open;
  Result := qryAux;
end;

end.
