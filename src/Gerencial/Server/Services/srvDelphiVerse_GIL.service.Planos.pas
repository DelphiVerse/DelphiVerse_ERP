unit srvDelphiVerse_GIL.service.Planos;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,

  ServerGIL.providers.ProviderConnection,
  untLibrary,

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
  FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,

  DataSet.Serialize;

type
  TdmGILConnectPlanos = class(TdmGILConnect)
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
  dmGILConnectPlanos: TdmGILConnectPlanos;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TdmGILConnect1 }

function TdmGILConnectPlanos.Atualizar(const AId: Int64;
  const AJson: TJSONObject): Boolean;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM planos WHERE id = :id';
  qryAux.UpdateOptions.UpdateTableName := 'planos';
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

function TdmGILConnectPlanos.Deletar(const AId: Int64): Boolean;
begin
  ListarPorId(AId);
  if not qryAux.IsEmpty then
  begin
    qryAux.Delete;
    Result := qryAux.ApplyUpdates(0) = 0;
  end;
end;

function TdmGILConnectPlanos.Inserir(const AJson: TJSONObject): Boolean;
begin
  qryAux.CachedUpdates:= True;
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM planos WHERE 1 <> 1';
  qryAux.UpdateOptions.UpdateTableName := 'planos';
  qryAux.UpdateOptions.KeyFields := 'id';
  qryAux.UpdateOptions.RefreshMode := rmManual; // Impede que ele tente recarregar a linha
  qryAux.UpdateOptions.CountUpdatedRecords := False; // Ignora a checagem restrita de 1 linha lida
  qryAux.Open;
  qryAux.LoadFromJSON(AJson, False);
  Result := qryAux.ApplyUpdates(0) = 0;
end;

function TdmGILConnectPlanos.ListarPorId(const AId: Int64): TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM planos WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;
  Result := qryAux;
end;

function TdmGILConnectPlanos.ListarTodos: TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM planos ORDER BY nome';
  qryAux.Open;
  Result := qryAux;
end;

end.
