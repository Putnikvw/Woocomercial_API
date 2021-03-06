unit uDMBase;

interface

uses
  System.SysUtils, System.Classes, Data.DB, DBAccess, MSAccess, MemDS, Vcl.Dialogs,
  FireDAC.Comp.Client, System.RegularExpressions, System.Variants, System.JSON;

type
  TDMBase = class(TDataModule)
    dbConnection: TMSConnection;
    qProductCategory: TMSQuery;
    InsertPGroup: TMSSQL;
    qProductGroup: TMSQuery;
  private
    FProdCategID: Integer;
    function RetriveString(AFullPath: Variant; const ASearchType: string): string;
    procedure LoadProdCateg(AData: TFDMemTable);
    procedure LoadProduct(AData: TFDMemTable);
    procedure LoadOrders(AData: TFDMemTable);
    procedure CompareProductCategories;
    procedure RefreshSQL;
    procedure WriteProdGrouptoWProdCategories;
    procedure GetID;
    property ProdCatID: Integer read FProdCategID write FProdCategID;
    function JSonArray: TJSONObject;
  public
    { Public declarations }
    procedure MainConnection(AServer, ALogin, APass, ADB: string);
    procedure DownloadData(AData: TFDMemTable; AType: string);
    procedure CompareCategories;
    function ReturnPOSTJSONString: string;
  end;

var
  DMBase: TDMBase;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDMBase }

function TDMBase.ReturnPOSTJSONString: string;
var
  A: TJSONObject;
begin
  try
    A := JSonArray;
    Result := A.ToJSON;
  finally
    A.Free;
  end;
end;

procedure TDMBase.CompareCategories;
begin
  CompareProductCategories;
end;

procedure TDMBase.CompareProductCategories;
begin
  InsertPGroup.Execute;
  RefreshSQL;
  WriteProdGrouptoWProdCategories;
end;

procedure TDMBase.DownloadData(AData: TFDMemTable; AType: string);
begin
  if AType = 'products/categories' then
    LoadProdCateg(AData);
  if AType = 'products' then
    LoadProduct(AData);
  if AType = 'orders' then
    LoadOrders(AData);
//  if AType = 'customers' then

end;

procedure TDMBase.GetID;
var
  Q: TMSQuery;
begin
  Q := TMSQuery.Create(nil);
  try
    Q.Connection := dbConnection;
    Q.SQL.Text := 'SELECT MAX(id) as MaxID FROM WooCommerceProductCategory';
    Q.Open;
    ProdCatID := Q.FieldByName('MaxID').AsInteger;
  finally
    Q.Free
  end;
end;

function TDMBase.JSonArray: TJSONObject;
var
  InnerObject, InnerFields: TJSONObject;
begin
  InnerObject := TJSONObject.Create;
  RefreshSQL;
  qProductCategory.First;
  while not qProductCategory.Eof do
  begin
    with qProductCategory do
    begin
      InnerObject.AddPair('id', FieldByName('id').AsString);
      InnerObject.AddPair('name', FieldByName('name').AsString);
      InnerObject.AddPair('slug', FieldByName('slug').AsString);
      InnerObject.AddPair('parent', FieldByName('parent').AsString);
      InnerObject.AddPair('description', FieldByName('description').AsString);
      InnerObject.AddPair('display', FieldByName('display').AsString);
      InnerObject.AddPair('image', FieldByName('image').AsString);
      InnerObject.AddPair('menu_order', FieldByName('menu_order').AsString);
      InnerObject.AddPair('count', FieldByName('count').AsString);
      InnerFields := TJSONObject.Create;
      InnerFields.AddPair('self', FieldByName('link_self').AsString);
      InnerFields.AddPair('collection', FieldByName('link_collection').AsString);
      InnerObject.AddPair('_links', InnerFields);
      Next;
    end;
  end;
  InnerObject := TJSONObject.ParseJSONValue(InnerObject.ToJSON) as TJSONObject;
  Result := InnerObject;
end;

procedure TDMBase.LoadOrders(AData: TFDMemTable);
  function GetCustomerGuid(A)
  function ClearString(AString: string): string;
  begin
    Result := StringReplace(StringReplace(AString, '<p>', '', [rfReplaceAll]), '</p>', '', [rfReplaceAll]);   
  end;

var
  qOrder, qWOrders: TMSQuery;
begin
  qOrder := TMSQuery.Create(nil);
  try
    qWOrders := TMSQuery.Create(nil);
    try      
      qOrder.SQL.Text := 'SELECT * from Orders';
      qWOrders.SQL.Text := 'SELECT * from WooCommerceOrder';
      qOrder.Connection := dbConnection;
      qWOrders.Connection := dbConnection;
      qOrder.Open;
      qWOrders.Open;
      AData.First;
      while not AData.Eof do
      begin
        if qOrder.Locate('ProductName', AData.FieldByName('name').AsString, []) then
          qOrder.Edit
        else
          qOrder.Append;
        qOrder.FieldByName('ProductNumber').AsString := AData.FieldByName('id').AsString;
        qOrder.FieldByName('ProductID').AsInteger := AData.FieldByName('id').AsInteger;
        qOrder.FieldByName('ProductName').AsString := AData.FieldByName('name').AsString;
        qOrder.FieldByName('ProductDescription').AsString := DeleteTags(AData.FieldByName('description').AsString);
        qOrder.FieldByName('Price').AsFloat := AData.FieldByName('price').AsFloat;
        qOrder.FieldByName('short_description').AsString := DeleteTags(AData.FieldByName('short_description').AsString);
        qOrder.FieldByName('CostPrice').AsFloat := AData.FieldByName('regular_price').AsFloat;
        qOrder.FieldByName('visible_webshop').AsBoolean := False;
        qOrder.Post;
        if not qWOrders.Locate('WooCommerceProductID', AData.FieldByName('id').AsInteger, []) then
        begin
          qWOrders.Append;
          qWOrders.FieldByName('WooCommerceProductID').AsInteger := AData.FieldByName('id').AsInteger;
          qWOrders.Post;
        end;        
        AData.Next;
      end;
    finally
      qWOrders.Free;
    end;
  finally
    qOrder.Free;
  end;

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
      FieldByName('image').AsString := RetriveString(AData.FieldByName('image').Value, 'src');
      FieldByName('menu_order').AsInteger := AData.FieldByName('menu_order').AsInteger;
      FieldByName('count').AsInteger := AData.FieldByName('count').AsInteger;
      FieldByName('link_self').AsString := RetriveString(AData.FieldByName('_links').Value, 'self');
      FieldByName('link_collection').AsString := RetriveString(AData.FieldByName('_links').Value, 'collection');
      Post;
    end;
    AData.Next;
  end;
end;

procedure TDMBase.LoadProduct(AData: TFDMemTable);
  function DeleteTags(AString: string): string;
  begin
    Result := StringReplace(StringReplace(AString, '<p>', '', [rfReplaceAll]), '</p>', '', [rfReplaceAll]);   
  end;

var
  qProduct, qWProduct: TMSQuery;
begin
  qProduct := TMSQuery.Create(nil);
  try
    qWProduct := TMSQuery.Create(nil);
    try      
      qProduct.SQL.Text := 'SELECT * from Product';
      qWProduct.SQL.Text := 'SELECT * from WooCommerceProduct';
      qProduct.Connection := dbConnection;
      qWProduct.Connection := dbConnection;
      qProduct.Open;
      qWProduct.Open;
      AData.First;
      while not AData.Eof do
      begin
        if qProduct.Locate('ProductName', AData.FieldByName('name').AsString, []) then
          qProduct.Edit
        else
          qProduct.Append;
        qProduct.FieldByName('ProductNumber').AsString := AData.FieldByName('id').AsString;
        qProduct.FieldByName('ProductID').AsInteger := AData.FieldByName('id').AsInteger;
        qProduct.FieldByName('ProductName').AsString := AData.FieldByName('name').AsString;
        qProduct.FieldByName('ProductDescription').AsString := DeleteTags(AData.FieldByName('description').AsString);
        qProduct.FieldByName('Price').AsFloat := AData.FieldByName('price').AsFloat;
        qProduct.FieldByName('short_description').AsString := DeleteTags(AData.FieldByName('short_description').AsString);
        qProduct.FieldByName('CostPrice').AsFloat := AData.FieldByName('regular_price').AsFloat;
        qProduct.FieldByName('visible_webshop').AsBoolean := False;
        qProduct.Post;
        if not qWProduct.Locate('WooCommerceProductID', AData.FieldByName('id').AsInteger, []) then
        begin
          qWProduct.Append;
          qWProduct.FieldByName('WooCommerceProductID').AsInteger := AData.FieldByName('id').AsInteger;
          qWProduct.Post;
        end;        
        AData.Next;
      end;
    finally
      QWProduct.Free;
    end;
  finally
    qProduct.Free;
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
  except
    on E: Exception do
      ShowMessage('Connection failed: ' + E.Message);
  end;
end;

function TDMBase.RetriveString(AFullPath: Variant; const ASearchType: string): string;
var
  TmpStr: string;
  A: TArray<string>;
  I: Integer;
begin
  if VarIsNull(AFullPath) then
    Result := ''
  else
  begin
    TmpStr := TRegEx.Replace(TRegEx.Replace(AFullPath, '\[/*', ''), '\]/*', '');
    TmpStr := TRegEx.Replace(TRegEx.Replace(TRegEx.Replace(TmpStr, '\{/*', ''), '\}/*', ''), '\"/*', '');
    A := TmpStr.Split([',']);
    for I := 0 to Length(A) - 1 do
      if A[I].contains(ASearchType) then
        Result := StringReplace(StringReplace(A[I], ASearchType + ':', '', [rfReplaceAll]), 'href:', '', [rfReplaceAll]);
  end;
end;

procedure TDMBase.WriteProdGrouptoWProdCategories;
begin
  GetID;
  qProductGroup.First;
  while not qProductGroup.Eof do
  begin
    if not qProductCategory.Locate('ProductGroupGUID', qProductGroup.FieldByName('ProductGroupGUID').AsString, []) then
    begin
      if qProductCategory.Locate('name', qProductGroup.FieldByName('ProductGroup').AsString, []) then
      begin
        qProductCategory.Edit;
        qProductCategory.FieldByName('ProductGroupGUID').AsString := qProductGroup.FieldByName('ProductGroupGUID').AsString;
        qProductCategory.Post
      end
      else
      begin
        Inc(FProdCategID, 1);
        with qProductCategory do
        begin
          Append;
          FieldByName('ProductGroupGUID').AsString := qProductGroup.FieldByName('ProductGroupGUID').AsString;
          FieldByName('name').AsString := qProductGroup.FieldByName('ProductGroup').AsString;
          FieldByName('id').AsInteger := ProdCatID;
          FieldByName('parent').AsInteger := 0;
          FieldByName('menu_order').AsInteger := 0;
          FieldByName('count').AsInteger := 0;
          Post;
        end;
      end;
    end;
    qProductGroup.Next;
  end;
end;

procedure TDMBase.RefreshSQL;
begin
  qProductCategory.Close;
  qProductGroup.Close;
  qProductCategory.Open;
  qProductGroup.Open;
end;

end.

