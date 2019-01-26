program WooCommerceSync;

uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {Main},
  dAPIConnection in 'dAPIConnection.pas' {dmAPIConnect: TDataModule},
  uDMBase in 'uDMBase.pas' {DMBase: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMain, Main);
  Application.CreateForm(TdmAPIConnect, dmAPIConnect);
  Application.CreateForm(TDMBase, DMBase);
  Application.Run;
end.
