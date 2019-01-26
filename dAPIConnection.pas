unit dAPIConnection;

interface

uses
  System.SysUtils, System.Classes, IPPeerClient, REST.Client, REST.Authenticator.Basic,
  Data.Bind.Components, Data.Bind.ObjectScope, Vcl.Dialogs, System.JSON, REST.Response.Adapter,
  Data.DB, Datasnap.DBClient, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Types, System.RegularExpressions,
  System.Variants;

type
  TdmAPIConnect = class(TDataModule)
    RESTClient: TRESTClient;
    RESTRequest: TRESTRequest;
    RESTResponse: TRESTResponse;
    HTTPBasicAuthenticator: THTTPBasicAuthenticator;
    RESTDataAdapter: TRESTResponseDataSetAdapter;
    mDataTable: TFDMemTable;
  private
    procedure ExecuteAPI(ACategory: string);
    procedure ClearTable;
    procedure RetriveData;
    function RetrivePath(AFullPath: string): string;
    { Private declarations }
  public
    procedure GETAPIData(AType: string);
    procedure POSTAPIData(AType: string);
    procedure APIConnection(AUserName, APassValue, AUrl: string);
  end;

var
  dmAPIConnect: TdmAPIConnect;

implementation

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

procedure TdmAPIConnect.ClearTable;
begin
  if mDataTable.RecordCount > 0 then
    mDataTable.EmptyDataSet;
end;

procedure TdmAPIConnect.RetriveData;
var
  I: Integer;
begin
  mDataTable.First;
  with mDataTable do
  begin
    while not Eof do
    begin
      for I := 0 to FieldCount - 1 do
      begin
        Fields.Fields[I].FullName;
        if Fields.Fields[I].FullName = 'image' then
          if not varisnull(Fields.Fields[I].Value) then
            RetrivePath(Fields.Fields[I].Value);
        Fields.Fields[I].Value;
      end;
      Next;
    end;
  end;
end;

procedure TdmAPIConnect.GETAPIData(AType: string);
begin
  RESTRequest.Method := TRESTRequestMethod.rmGET;
  ClearTable;
  ExecuteAPI(AType);
  RetriveData;
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
  RESTRequest.Method := TRESTRequestMethod.rmPOST;
  ExecuteAPI(AType);
end;

function TdmAPIConnect.RetrivePath(AFullPath: string): string;
var
  TmpStr: string;
  A: TArray<string>;
  I: Integer;
begin
  TmpStr := TRegEx.Replace(TRegEx.Replace(AFullPath, '\[/*', ''), '\]/*', '');
  TmpStr := TRegEx.Replace(TRegEx.Replace(TRegEx.Replace(TmpStr, '\{/*', ''), '\}/*', ''), '\"/*', '');
  A := TmpStr.Split([',']);
  for I := 0 to Length(A) - 1 do
    if A[I].contains('src') then
      Result := StringReplace(StringReplace(A[I], 'src:', '', [rfReplaceAll]), 'href:', '', [rfReplaceAll]);
end;

end.

