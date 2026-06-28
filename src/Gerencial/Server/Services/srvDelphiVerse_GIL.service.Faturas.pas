unit srvDelphiVerse_GIL.service.Faturas;

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
  TdmGILConnectFaturas = class(TdmGILConnect)
  private
    { Private declarations }
  public
    { Public declarations }
    function ListarTodas: TFDQuery;
    function ListarPorId(const AId: Int64): TFDQuery;
    function ListarPorCliente(const AClienteId: Int64): TFDQuery;
    function Inserir(const AJson: TJSONObject): Boolean;
    function Atualizar(const AId: Int64; const AJson: TJSONObject): Boolean;
    function BaixarFatura(const AId: Int64; const AFormaPagamento: string): Boolean;
    function Deletar(const AId: Int64): Boolean;
  end;

var
  dmGILConnectFaturas: TdmGILConnectFaturas;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TdmGILConnect1 }

function TdmGILConnectFaturas.Atualizar(const AId: Int64;
  const AJson: TJSONObject): Boolean;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM faturas WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;
  if not qryAux.IsEmpty then
  begin
    qryAux.MergeFromJSONObject(AJson, False);
    Result := qryAux.ApplyUpdates(0) = 0;
  end;
end;

function TdmGILConnectFaturas.BaixarFatura(const AId: Int64;
  const AFormaPagamento: string): Boolean;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM faturas WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;

  if not qryAux.IsEmpty then
  begin
    qryAux.Edit;
    qryAux.FieldByName('status').AsString := 'PAGO';
    qryAux.FieldByName('forma_pagamento').AsString := UpperCase(AFormaPagamento);
    qryAux.FieldByName('data_pagamento').AsDateTime := Now;
    qryAux.Post;
    Result := qryAux.ApplyUpdates(0) = 0;
  end
  else
    Result := False;
end;

function TdmGILConnectFaturas.Deletar(const AId: Int64): Boolean;
begin
  ListarPorId(AId);
  if not qryAux.IsEmpty then
  begin
    qryAux.Delete;
    Result := qryAux.ApplyUpdates(0) = 0;
  end;
end;

function TdmGILConnectFaturas.Inserir(const AJson: TJSONObject): Boolean;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM faturas WHERE 1 <> 1';
  qryAux.Open;
  qryAux.LoadFromJSON(AJson, False);
  Result := qryAux.ApplyUpdates(0) = 0;
end;

function TdmGILConnectFaturas.ListarPorCliente(const AClienteId: Int64): TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM faturas WHERE cliente_id = :cliente_id ORDER BY data_vencimento DESC';
  qryAux.ParamByName('cliente_id').AsLargeInt := AClienteId;
  qryAux.Open;
  Result := qryAux;
end;

function TdmGILConnectFaturas.ListarPorId(const AId: Int64): TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM faturas WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;
  Result := qryAux;
end;

function TdmGILConnectFaturas.ListarTodas: TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM faturas ORDER BY data_vencimento ASC';
  qryAux.Open;
  Result := qryAux;
end;

end.
