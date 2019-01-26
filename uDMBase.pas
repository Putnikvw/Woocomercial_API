unit uDMBase;

interface

uses
  System.SysUtils, System.Classes, Data.DB, DBAccess, MSAccess, MemDS, Vcl.Dialogs,
  FireDAC.Comp.Client, System.RegularExpressions;

type
  TDMBase = class(TDataModule)
    dbConnection: TMSConnection;
    qProductCategory: TMSQuery;
  private
    function RetrivePath(AFullPath: Variant; const ASearchType: string): string;
    procedure LoadProdCateg(AData: TFDMemTable);
  public
    { Public declarations }
    procedure MainConnection(AServer, ALogin, APass, ADB: string);
    procedure DownloadProdCateg(AData: TFDMemTable);
  end;

var
  DMBase: TDMBase;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDMBase }

procedure TDMBase.DownloadProdCateg(AData: TFDMemTable);
begin

end;

procedure TDMBase.LoadProdCateg(AData: TFDMemTable);
begin
  qProductCategory.Close;
  qProductCategory.Open;
  AData.First;
  while not AData.Eof do
  begin
    if qProductCategory.Locate('id', AData.FieldByName('id').AsInteger, []) then
      qProductCategory.Edit
    else
      qProductCategory.Append;
    with qProductCategory do
    begin
      FieldByName('id').AsInteger := AData.FieldByName('id').AsInteger;
      FieldByName('name').AsString := AData.FieldByName('name').AsString;
      FieldByName('slug').AsString := AData.FieldByName('slug').AsString;
      FieldByName('parent').AsInteger := AData.FieldByName('parent').AsInteger;
      FieldByName('description').AsString := AData.FieldByName('description').AsString;
      FieldByName('display').AsString := AData.FieldByName('display').AsString;
      FieldByName('image').AsString := RetrivePath(AData.FieldByName('image').AsString, 'src');
      FieldByName('menu_order').AsInteger := AData.FieldByName('menu_order').AsInteger;
      FieldByName('count').AsInteger := AData.FieldByName('count').AsInteger;
      FieldByName('link_self').AsString := RetrivePath(AData.FieldByName('_link').AsString, 'self');
      FieldByName('link_self').AsString := RetrivePath(AData.FieldByName('_link').AsString, 'collection');
      Post;
    end;

  end;

end;

procedure TDMBase.MainConnection(AServer, ALogin, APass, ADB: string);
begin
  dbConnection.Server := AServer;
  dbConnection.Database := ADB;
  dbConnection.Username := ALogin;
  dbConnection.Password := APass;
  try
    dbConnection.Connect;
    ShowMessage('Connection OK');
  except
    on E: Exception do
      ShowMessage('Connection failed: ' + E.Message);
  end;
end;


function TDMBase.RetrivePath(AFullPath: Variant; const ASearchType: string): string;
var
  TmpStr: string;
  A: TArray<string>;
  I: Integer;
begin
  if VarIsNull(AFullPath) then
	Exit;
  TmpStr := TRegEx.Replace(TRegEx.Replace(AFullPath, '\[/*', ''), '\]/*', '');
  TmpStr := TRegEx.Replace(TRegEx.Replace(TRegEx.Replace(TmpStr, '\{/*', ''), '\}/*', ''), '\"/*', '');
  A := TmpStr.Split([',']);
  for I := 0 to Length(A) - 1 do
    if A[I].Contains(ASearchType) then
      Result := StringReplace(StringReplace(A[I], ASearchType + ':', '', [rfReplaceAll]), 'href:', '', [rfReplaceAll]);
end;

end.

