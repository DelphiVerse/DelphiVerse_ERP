unit Server.providers.ProviderConnection;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,

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
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet;

type
  TdmSrvConnect = class(TDataModule)
    conConnect: TFDConnection;
    drvMySql: TFDPhysMySQLDriverLink;
    qryAux: TFDQuery;
  private
    { Private declarations }
  public
    { Public declarations }
    procedure DataModuleCreate(Sender: TObject);
    function Gravar(aJson: TJSONArray): Boolean;
  end;

var
  dmSrvConnect: TdmSrvConnect;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

uses
  DataSet.Serialize;

procedure TdmSrvConnect.DataModuleCreate(Sender: TObject);
begin
  inherited Create(nil);
end;

function TdmSrvConnect.Gravar(aJson: TJSONArray): Boolean;
begin
  qryAux.SQL.Add(' where 1 <> 1');
  qryAux.Open();
  qryAux.LoadFromJSON(aJson, False);
  Result:= qryAux.ApplyUpdates(0) = 0;
end;

end.
