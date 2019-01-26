unit TestfrmMain;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, System.Variants, System.SysUtils, REST.Client, MSAccess,
  Winapi.Windows, IPPeerClient, Vcl.Dialogs, RTFLabel, Vcl.Forms, REST.Response.Adapter,
  AdvPanel, Vcl.Controls, frmMain, AdvOfficePagerStylers, AdvOfficePager,
  Data.Bind.Components, System.Classes, Vcl.ExtCtrls, Winapi.Messages,
  Data.Bind.ObjectScope, DBAccess, AdvGDIPicture, Vcl.Graphics, Data.DB, Vcl.StdCtrls,
  AdvAppStyler, REST.Authenticator.Simple;

type
  // Test methods for class TMain

  TestTMain = class(TTestCase)
  strict private
    FMain: TMain;
  public
    procedure SetUp; override;
    procedure TearDown; override;
    procedure TestbtnDownlProdCategoriesClick;
  published
    procedure TestbtnConnectionClick;
  end;

implementation

procedure TestTMain.SetUp;
begin
  FMain := TMain.Create(nil);
end;

procedure TestTMain.TearDown;
begin
  FMain.Free;
  FMain := nil;
end;

procedure TestTMain.TestbtnConnectionClick;
var
  Sender: TObject;
begin
  // TODO: Setup method call parameters
  FMain.btnConnectionClick(Sender);
  // TODO: Validate method results
end;

procedure TestTMain.TestbtnDownlProdCategoriesClick;
var
  Sender: TObject;
begin
  // TODO: Setup method call parameters
  FMain.btnDownlProdCategoriesClick(Sender);
  // TODO: Validate method results
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTMain.Suite);
end.

