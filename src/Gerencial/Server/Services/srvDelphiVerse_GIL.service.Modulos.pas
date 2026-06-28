unit srvDelphiVerse_GIL.service.Modulos;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,

  ServerGIL.providers.ProviderConnection,

  Data.DB,

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
  FireDAC.Comp.Client,

  DataSet.Serialize;

type
  TdmGILConnectModulos = class(TdmGILConnect)
  private
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
  dmGILConnectModulos: TdmGILConnectModulos;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TdmGILConnectModulos }

function TdmGILConnectModulos.Atualizar(const AId: Int64;
  const AJson: TJSONObject): Boolean;
begin
  qryAux.CachedUpdates:= True;
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM modulos WHERE id = :id';
  qryAux.UpdateOptions.UpdateTableName := 'modulos';
  qryAux.UpdateOptions.KeyFields := 'id';
  qryAux.UpdateOptions.RefreshMode := rmManual;
  qryAux.UpdateOptions.CountUpdatedRecords := False;
  qryAux.CachedUpdates:= True;
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;
  if not qryAux.IsEmpty then
  begin
    qryAux.MergeFromJSONObject(AJson, False);
    Result := qryAux.ApplyUpdates(0) = 0;
  end;
end;

function TdmGILConnectModulos.Deletar(const AId: Int64): Boolean;
begin
  ListarPorId(AId);
  if not qryAux.IsEmpty then
  begin
    qryAux.Delete;
    Result := qryAux.ApplyUpdates(0) = 0;
  end;
end;

function TdmGILConnectModulos.Inserir(const AJson: TJSONObject): Boolean;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM modulos WHERE 1 <> 1';
  qryAux.UpdateOptions.UpdateTableName := 'modulos';
  qryAux.UpdateOptions.KeyFields := 'id';
  qryAux.UpdateOptions.RefreshMode := rmManual;
  qryAux.UpdateOptions.CountUpdatedRecords := False;
  qryAux.CachedUpdates:= True;
  qryAux.Open;
  qryAux.LoadFromJSON(AJson, False);
  Result := qryAux.ApplyUpdates(0) = 0;
end;

function TdmGILConnectModulos.ListarPorId(const AId: Int64): TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM modulos WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;
  Result := qryAux;
end;

function TdmGILConnectModulos.ListarTodos: TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM modulos ORDER BY nome';
  qryAux.Open;
  Result := qryAux;
end;

end.
