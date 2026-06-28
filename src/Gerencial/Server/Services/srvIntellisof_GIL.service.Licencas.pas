unit srvIntellisof_GIL.service.Licencas;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.Variants,

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
  TdmGILConnectLicencas = class(TdmGILConnect)
  private
    { Private declarations }
    function CalcularValorLicenca(const APlanoId, AModuloId: Int64): Currency;
  public
    { Public declarations }
    function ListarTodas: TFDQuery;
    function ListarPorId(const AId: Int64): TFDQuery;
    function Inserir(const AJson: TJSONObject): Boolean;
    function Atualizar(const AId: Int64; const AJson: TJSONObject): Boolean;
    function Deletar(const AId: Int64): Boolean;
  end;

var
  dmGILConnectLicencas: TdmGILConnectLicencas;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

{ TdmGILConnectLicencas }

function TdmGILConnectLicencas.Atualizar(const AId: Int64;
  const AJson: TJSONObject): Boolean;
var
  vPlanoId, vModuloId: Int64;
  begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM licencas WHERE id = :id';
  qryAux.UpdateOptions.UpdateTableName := 'licencas';
  qryAux.UpdateOptions.KeyFields := 'id';
  qryAux.UpdateOptions.RefreshMode := rmManual;
  qryAux.UpdateOptions.CountUpdatedRecords := False;
  qryAux.CachedUpdates:= True;
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;

  if not qryAux.IsEmpty then
  begin
    qryAux.MergeFromJSONObject(AJson, False);

    // Caso tenham alterado o plano ou módulo no update, recalcula o valor
//    vPlanoId := qryAux.FieldByName('plano_id').AsLargeInt;
//    vModuloId := qryAux.FieldByName('modulo_id').AsLargeInt;
//    qryAux.FieldByName('valor_total').AsCurrency := CalcularValorLicenca(vPlanoId, vModuloId);

    Result := qryAux.ApplyUpdates(0) = 0;
  end;
end;

function TdmGILConnectLicencas.CalcularValorLicenca(const APlanoId,
  AModuloId: Int64): Currency;
var
  vValorPlano, vValorModulo: Currency;
  vRetornoDb: Variant;
begin
  vValorPlano := 0;
  vValorModulo := 0;

  // Busca valor base do Plano usando ExecSQLScalar (retorna o valor direto do campo)
  vRetornoDb := conConnectGIL.ExecSQLScalar('SELECT valor_base FROM planos WHERE id = :id', [APlanoId]);
  if not VarIsNull(vRetornoDb) then
    vValorPlano := vRetornoDb;

  // Busca valor adicional do Módulo/Nicho
  vRetornoDb := conConnectGIL.ExecSQLScalar('SELECT valor_adicional FROM modulos WHERE id = :id', [AModuloId]);
  if not VarIsNull(vRetornoDb) then
    vValorModulo := vRetornoDb;

  Result := vValorPlano + vValorModulo;
end;

function TdmGILConnectLicencas.Deletar(const AId: Int64): Boolean;
begin
  ListarPorId(AId);
  if not qryAux.IsEmpty then
  begin
    qryAux.Delete;
    Result := qryAux.ApplyUpdates(0) = 0;
  end;
end;

function TdmGILConnectLicencas.Inserir(const AJson: TJSONObject): Boolean;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM licencas WHERE 1 <> 1';
  qryAux.UpdateOptions.UpdateTableName := 'licencas';
  qryAux.UpdateOptions.KeyFields := 'id';
  qryAux.UpdateOptions.RefreshMode := rmManual;
  qryAux.UpdateOptions.CountUpdatedRecords := False;
  qryAux.Open;
  qryAux.LoadFromJSON(AJson, False);
  Result := qryAux.ApplyUpdates(0) = 0;
end;

function TdmGILConnectLicencas.ListarPorId(const AId: Int64): TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM licencas WHERE id = :id';
  qryAux.ParamByName('id').AsLargeInt := AId;
  qryAux.Open;
  Result := qryAux;
end;

function TdmGILConnectLicencas.ListarTodas: TFDQuery;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT * FROM licencas ORDER BY data_vencimento DESC';
  qryAux.Open;
  Result := qryAux;
end;

end.
