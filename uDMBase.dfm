object DMBase: TDMBase
  OldCreateOrder = False
  Height = 300
  Width = 412
  object dbConnection: TMSConnection
    Left = 32
    Top = 24
  end
  object qProductCategory: TMSQuery
    Connection = dbConnection
    SQL.Strings = (
      'Select * from WooCommerceProductCategory')
    Left = 32
    Top = 80
  end
end
