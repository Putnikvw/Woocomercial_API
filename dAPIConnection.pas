unit dAPIConnection;

interface

uses
  System.SysUtils, System.Classes, IPPeerClient, REST.Client, REST.Authenticator.Basic,
  Data.Bind.Components, Data.Bind.ObjectScope, Vcl.Dialogs, System.JSON, REST.Response.Adapter,
  Data.DB, Datasnap.DBClient, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Types, System.RegularExpressions,
  System.Variants, MemDS, MSAccess;

type
  TdmAPIConnect = class(TDataModule)
    RESTClient: TRESTClient;
    RESTRequest: TRESTRequest;
    RESTResponse: TRESTResponse;
    HTTPBasicAuthenticator: THTTPBasicAuthenticator;
    RESTDataAdapter: TRESTResponseDataSetAdapter;
    GETTable: TFDMemTable;
  private
    FServer: string;
    FLogin: string;
    FPass: string;
    FDB: string;
    procedure ExecuteAPI(ACategory: string);
    procedure ClearTable(ADataSource: TFDMemTable);
    procedure RetriveData;
    procedure CheckConnect;
    { Private declarations }
  public
    procedure GETAPIData(AType: string);
    procedure POSTAPIData(AType: string);
    procedure APIConnection(AUserName, APassValue, AUrl: string);
    procedure DBConnection;
    procedure CompareProdCateg;
    property Server: string read FServer write FServer;
    property Login: string read FLogin write FLogin;
    property Password: string read FPass write FPass;
    property DataBase: string read FDB write FDB;
  end;

var
  dmAPIConnect: TdmAPIConnect;

implementation

  uses uDMBase;
{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TdmAPIConnect }

procedure TdmAPIConnect.APIConnection(AUserName, APassValue, AUrl: string);
begin
  try
    HTTPBasicAuthenticator.Username := AUserName;
    HTTPBasicAuthenticator.Password := APassValue;
    RESTClient.BaseURL := AUrl;
  except
    on E: Exception do
      ShowMessage('API connection failed: ' + E.Message);
  end;
end;

procedure TdmAPIConnect.CheckConnect;
begin
  if not DMBase.dbConnection.Connected then
    DBConnection;
end;

procedure TdmAPIConnect.ClearTable(ADataSource: TFDMemTable);
begin
  if ADataSource.RecordCount > 0 then
    ADataSource.EmptyDataSet;
end;

procedure TdmAPIConnect.CompareProdCateg;
begin
  CheckConnect;
  DMBase.DownloadData(GETTable, 'products/categories');
  DMBase.CompareCategories;
end;

procedure TdmAPIConnect.DBConnection;
begin
  DMBase.MainConnection(Server, Login, Password, DataBase);
end;

procedure TdmAPIConnect.RetriveData;
var
  I: Integer;
begin
  GETTable.First;
  with GETTable do
  begin
    while not Eof do
    begin
      for I := 0 to FieldCount - 1 do
      begin
        Fields.Fields[I].FullName;
        if Fields.Fields[I].FullName = 'image' then
          if not VarIsNull(Fields.Fields[I].Value) then
        Fields.Fields[I].Value;
      end;
      Next;
    end;
  end;
end;

procedure TdmAPIConnect.GETAPIData(AType: string);
begin
  RESTRequest.Method := TRESTRequestMethod.rmGET;
  ClearTable(GETTable);
  RESTDataAdapter.Dataset := GETTable;
  ExecuteAPI(AType);
  CheckConnect;
  DMBase.DownloadData(GETTable, AType);
end;

procedure TdmAPIConnect.ExecuteAPI(ACategory: string);
begin
  RESTRequest.Resource := ACategory;
  try
    RESTRequest.Execute;
  except
    on E: Exception do
      ShowMessage('Cannot get the data by API : ' + E.Message);
  end;
end;

procedure TdmAPIConnect.POSTAPIData(AType: string);
begin
  CheckConnect;
  RESTRequest.Method := TRESTRequestMethod.rmPOST;
  RESTRequest.AddBody(DMBase.ReturnPOSTJSONString, ctAPPLICATION_JSON);
  ExecuteAPI(AType);
end;

end.

