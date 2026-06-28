unit ServerGIL.providers.ProviderConnection;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,

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
  TdmGILConnect = class(TDataModule)
    conConnectGIL: TFDConnection;
    drvMySql: TFDPhysMySQLDriverLink;
    qryAux: TFDQuery;
    conConnectERP: TFDConnection;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure DataModuleCreate(Sender: TObject);
    function Gravar(aJson: TJSONArray): Boolean;
  end;

var
  dmGILConnect: TdmGILConnect;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

uses
  DataSet.Serialize, DataSet.Serialize.Config, DataSet.Serialize.Consts;

procedure TdmGILConnect.DataModuleCreate(Sender: TObject);
begin
  inherited;
  TDataSetSerializeConfig.GetInstance.CaseNameDefinition := cndLowerCamelCase;
end;

function TdmGILConnect.Gravar(aJson: TJSONArray): Boolean;
begin
  qryAux.SQL.Add(' where 1 <> 1');
  qryAux.Open();
  qryAux.LoadFromJSON(aJson, False);
  Result:= qryAux.ApplyUpdates(0) = 0;
end;

end.
