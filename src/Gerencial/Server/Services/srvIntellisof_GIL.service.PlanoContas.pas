unit srvIntellisof_GIL.service.PlanoContas;

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
  TdmGILConnectPlanoContas = class(TdmGILConnect)
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
  dmGILConnectPlanoContas: TdmGILConnectPlanoContas;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TdmGILConnectPlanoContas }

function TdmGILConnectPlanoContas.Atualizar(const AId: Int64;
  const AJson: TJSONObject): Boolean;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM plano_contas WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.UpdateOptions.UpdateTableName := 'plano_contas';
  qryAux.UpdateOptions.KeyFields := 'id';
  qryAux.UpdateOptions.RefreshMode := rmManual;
  qryAux.UpdateOptions.CountUpdatedRecords := True;
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

function TdmGILConnectPlanoContas.Deletar(const AId: Int64): Boolean;
begin
  ListarPorId(AId);
  if not qryAux.IsEmpty then
  begin
    qryAux.Delete;
    Result := qryAux.ApplyUpdates(0) = 0;
  end;
end;

function TdmGILConnectPlanoContas.Inserir(const AJson: TJSONObject): Boolean;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM plano_contas WHERE 1 <> 1';

  qryAux.UpdateOptions.UpdateTableName := 'plano_contas';
  qryAux.UpdateOptions.KeyFields := 'id';
  qryAux.UpdateOptions.RefreshMode := rmManual;
  qryAux.UpdateOptions.CountUpdatedRecords := False;
  qryAux.CachedUpdates:= True;
  qryAux.Open;
  qryAux.LoadFromJSON(AJson, False);
  Result := qryAux.ApplyUpdates(0) = 0;
end;

function TdmGILConnectPlanoContas.ListarPorId(const AId: Int64): TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM plano_contas WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;
  Result := qryAux;
end;

function TdmGILConnectPlanoContas.ListarTodas: TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM plano_contas ORDER BY codigo_contabil, nome';
  qryAux.Open;
  Result := qryAux;
end;

end.
