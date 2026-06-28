unit srvIntellisof_GIL.service.CentroCustos;

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
  TdmGILConnectCentroCustos = class(TdmGILConnect)
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
  dmGILConnectCentroCustos: TdmGILConnectCentroCustos;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TdmGILConnectCentroCustos }

function TdmGILConnectCentroCustos.Atualizar(const AId: Int64;
  const AJson: TJSONObject): Boolean;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM centro_custos WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.CachedUpdates:= True;
  qryAux.UpdateOptions.UpdateTableName := 'centro_custos';
  qryAux.UpdateOptions.KeyFields := 'id';
  qryAux.UpdateOptions.RefreshMode := rmManual;
  qryAux.UpdateOptions.CountUpdatedRecords := False;

  qryAux.Open;
  if not qryAux.IsEmpty then
  begin
    qryAux.MergeFromJSONObject(AJson, False);
    Result := qryAux.ApplyUpdates(0) = 0;
  end
  else
    Result := False;
end;

function TdmGILConnectCentroCustos.Deletar(const AId: Int64): Boolean;
begin
  ListarPorId(AId);
  if not qryAux.IsEmpty then
  begin
    qryAux.Delete;
    Result := qryAux.ApplyUpdates(0) = 0;
  end;
end;

function TdmGILConnectCentroCustos.Inserir(const AJson: TJSONObject): Boolean;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM centro_custos WHERE 1 <> 1';
  qryAux.CachedUpdates:= True;
  qryAux.UpdateOptions.UpdateTableName := 'centro_custos';
  qryAux.UpdateOptions.KeyFields := 'id';
  qryAux.UpdateOptions.RefreshMode := rmManual;
  qryAux.UpdateOptions.CountUpdatedRecords := False;

  qryAux.Open;
  qryAux.LoadFromJSON(AJson, False);
  Result := qryAux.ApplyUpdates(0) = 0;
end;

function TdmGILConnectCentroCustos.ListarPorId(const AId: Int64): TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM centro_custos WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;
  Result := qryAux;
end;

function TdmGILConnectCentroCustos.ListarTodas: TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM centro_custos ORDER BY nome';
  qryAux.Open;
  Result := qryAux;
end;

end.
