object DMBase: TDMBase
  OldCreateOrder = False
  Height = 300
  Width = 412
  object dbConnection: TMSConnection
    Left = 40
    Top = 24
  end
  object qProductCategory: TMSQuery
    Connection = dbConnection
    SQL.Strings = (
      'Select * from WooCommerceProductCategory')
    Left = 40
    Top = 80
  end
  object InsertPGroup: TMSSQL
    Connection = dbConnection
    SQL.Strings = (
      'INSERT INTO PRODUCTGROUP (PRODUCTGROUP)'
      'SELECT NAME FROM WOOCOMMERCEPRODUCTCATEGORY'
      'WHERE PRODUCTGROUPGUID IS NULL')
    Left = 40
    Top = 152
  end
  object qProductGroup: TMSQuery
    Connection = dbConnection
    SQL.Strings = (
      'SELECT * from ProductGroup')
    Left = 120
    Top = 24
  end
end
