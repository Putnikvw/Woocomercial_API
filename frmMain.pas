unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, AdvGDIPicture,
  AdvAppStyler, AdvPanel, Vcl.ExtCtrls, AdvOfficePager, AdvOfficePagerStylers,
  Vcl.StdCtrls, RTFLabel, Data.DB, DBAccess, MSAccess, IPPeerClient,
  Data.Bind.Components, Data.Bind.ObjectScope;

type
  TMain = class(TForm)
    AdvOfficePager1: TAdvOfficePager;
    AdvOfficePager11: TAdvOfficePage;
    AdvOfficePager12: TAdvOfficePage;
    AdvOfficePager13: TAdvOfficePage;
    AdvOfficePagerOfficeStyler1: TAdvOfficePagerOfficeStyler;
    AdvPanel1: TAdvPanel;
    AdvPanelStyler1: TAdvPanelStyler;
    AdvFormStyler1: TAdvFormStyler;
    AdvGDIPPicture1: TAdvGDIPPicture;
    eServerName: TEdit;
    eDataBase: TEdit;
    eUserName: TEdit;
    ePassword: TEdit;
    eBaseUrl: TEdit;
    eKey: TEdit;
    ePassValue: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    btnOrders: TButton;
    AdvOfficePage1: TAdvOfficePage;
    AdvOfficePage2: TAdvOfficePage;
    btnProdCategories: TButton;
    RTFLabel1: TRTFLabel;
    btnCompareCategories: TButton;
    btnUploadProdCategories: TButton;
    AdvOfficePage3: TAdvOfficePage;
    RTFLabel2: TRTFLabel;
    btnProducts: TButton;
    btnCompareProducts: TButton;
    btnUploadProducts: TButton;
    btnCustomers: TButton;
    btnUpdateCustomers: TButton;
    btnUploadCustomers: TButton;
    RTFLabel3: TRTFLabel;
    RTFLabel4: TRTFLabel;
    RTFLabel5: TRTFLabel;
    btnConnection: TButton;
    procedure btnConnectionClick(Sender: TObject);
    procedure btnProdCategoriesClick(Sender: TObject);
  private
    procedure APIConnect;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;

implementation

uses
  dAPIConnection, uDMBase;

resourcestring
  rsProdCategory = 'products/categories';
  rsProduct = 'products';
  rsOrders = 'orders';
  rsCustomers = 'customers';

{$R *.dfm}

procedure TMain.btnConnectionClick(Sender: TObject);
begin
  DMBase.MainConnection(eServerName.Text, eUserName.Text, ePassword.Text, eDataBase.Text);
end;

procedure TMain.btnProdCategoriesClick(Sender: TObject);
begin
  APIConnect;
  if Sender = btnProdCategories then
    dmAPIConnect.GETAPIData(rsProdCategory);
  if Sender = btnProducts then
    dmAPIConnect.GETAPIData(rsProduct);
  if Sender = btnOrders then
    dmAPIConnect.GETAPIData(rsOrders);
  if Sender = btnCustomers then
    dmAPIConnect.GETAPIData(rsCustomers);
end;

procedure TMain.APIConnect;
begin
  dmAPIConnect.APIConnection(eKey.Text, ePassValue.Text, eBaseUrl.Text);
end;

end.

