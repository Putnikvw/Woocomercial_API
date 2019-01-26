object dmAPIConnect: TdmAPIConnect
  OldCreateOrder = False
  Height = 389
  Width = 485
  object RESTClient: TRESTClient
    Authenticator = HTTPBasicAuthenticator
    Accept = 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    AcceptCharset = 'UTF-8, *;q=0.8'
    Params = <>
    HandleRedirects = True
    RaiseExceptionOn500 = False
    Left = 88
    Top = 96
  end
  object RESTRequest: TRESTRequest
    Client = RESTClient
    Params = <>
    Response = RESTResponse
    SynchronizedEvents = False
    Left = 88
    Top = 152
  end
  object RESTResponse: TRESTResponse
    ContentType = 'application/json'
    Left = 88
    Top = 200
  end
  object HTTPBasicAuthenticator: THTTPBasicAuthenticator
    Left = 88
    Top = 48
  end
  object RESTDataAdapter: TRESTResponseDataSetAdapter
    Dataset = mDataTable
    FieldDefs = <>
    Response = RESTResponse
    Left = 88
    Top = 256
  end
  object mDataTable: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 80
    Top = 320
  end
end
