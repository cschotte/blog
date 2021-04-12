param actionGroups_Application_Insights_Smart_Detection_name string
param components_clemens_api_externalid string
param components_clemens_externalid string
param components_clemens_go_externalid string
param components_clemens_web_externalid string
param dnszones_caverace_com_name string
param dnszones_clemens_ms_name string
param profiles_clemens_name string
param smartdetectoralertrules_failure_anomalies_clemens_api_name string
param smartdetectoralertrules_failure_anomalies_clemens_go_name string
param smartdetectoralertrules_failure_anomalies_clemens_name string
param smartdetectoralertrules_failure_anomalies_clemens_web_name string
param storageAccounts_clemensblog_name string
param vaults_clemens_keyvault_name string

resource profiles_clemens_name_resource 'Microsoft.Cdn/profiles@2020-09-01' = {
  kind: 'cdn'
  location: 'WestUs'
  name: profiles_clemens_name
  properties: {}
  sku: {
    name: 'Standard_Microsoft'
  }
}

resource actionGroups_Application_Insights_Smart_Detection_name_resource 'microsoft.insights/actionGroups@2019-06-01' = {
  location: 'Global'
  name: actionGroups_Application_Insights_Smart_Detection_name
  properties: {
    armRoleReceivers: [
      {
        name: 'Monitoring Contributor'
        roleId: '749f88d5-cbae-40b8-bcfc-e573ddc772fa'
        useCommonAlertSchema: true
      }
      {
        name: 'Monitoring Reader'
        roleId: '43d0d8ad-25c7-4714-9337-8ba259a9fe05'
        useCommonAlertSchema: true
      }
    ]
    automationRunbookReceivers: []
    azureAppPushReceivers: []
    azureFunctionReceivers: []
    emailReceivers: []
    enabled: true
    groupShortName: 'SmartDetect'
    itsmReceivers: []
    logicAppReceivers: []
    smsReceivers: []
    voiceReceivers: []
    webhookReceivers: []
  }
}

resource vaults_clemens_keyvault_name_resource 'Microsoft.KeyVault/vaults@2020-04-01-preview' = {
  location: 'westeurope'
  name: vaults_clemens_keyvault_name
  properties: {
    accessPolicies: [
      {
        objectId: '3315d2e2-13fd-4a26-a981-d1df3760de38'
        permissions: {
          certificates: []
          keys: []
          secrets: [
            'get'
          ]
        }
        tenantId: '9be79373-29bb-4b8a-a999-495ad397f5ae'
      }
      {
        objectId: '18d2423e-a5f6-441c-98e6-e765d08b636e'
        permissions: {
          certificates: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
            'managecontacts'
            'manageissuers'
            'getissuers'
            'listissuers'
            'setissuers'
            'deleteissuers'
          ]
          keys: [
            'get'
            'list'
            'update'
            'create'
            'import'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
          secrets: [
            'get'
            'list'
            'set'
            'delete'
            'recover'
            'backup'
            'restore'
          ]
        }
        tenantId: '9be79373-29bb-4b8a-a999-495ad397f5ae'
      }
      {
        objectId: '679ae3d1-6049-45bd-9752-6acab57ebfa6'
        permissions: {
          certificates: []
          keys: []
          secrets: [
            'get'
            'list'
          ]
        }
        tenantId: '9be79373-29bb-4b8a-a999-495ad397f5ae'
      }
    ]
    enableRbacAuthorization: false
    enableSoftDelete: true
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    provisioningState: 'Succeeded'
    sku: {
      family: 'A'
      name: 'standard'
    }
    softDeleteRetentionInDays: 90
    tenantId: '9be79373-29bb-4b8a-a999-495ad397f5ae'
    vaultUri: 'https://${vaults_clemens_keyvault_name}.vault.azure.net/'
  }
}

resource dnszones_caverace_com_name_resource 'Microsoft.Network/dnszones@2018-05-01' = {
  location: 'global'
  name: dnszones_caverace_com_name
  properties: {
    zoneType: 'Public'
  }
}

resource dnszones_clemens_ms_name_resource 'Microsoft.Network/dnszones@2018-05-01' = {
  location: 'global'
  name: dnszones_clemens_ms_name
  properties: {
    zoneType: 'Public'
  }
}

resource storageAccounts_clemensblog_name_resource 'Microsoft.Storage/storageAccounts@2021-01-01' = {
  kind: 'StorageV2'
  location: 'westeurope'
  name: storageAccounts_clemensblog_name
  properties: {
    accessTier: 'Hot'
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
    largeFileSharesState: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
    }
    supportsHttpsTrafficOnly: true
  }
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
}

resource smartdetectoralertrules_failure_anomalies_clemens_name_resource 'microsoft.alertsmanagement/smartdetectoralertrules@2019-06-01' = {
  location: 'global'
  name: smartdetectoralertrules_failure_anomalies_clemens_name
  properties: {
    actionGroups: {
      groupIds: [
        actionGroups_Application_Insights_Smart_Detection_name_resource.id
      ]
    }
    description: 'Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls.'
    detector: {
      description: 'Detects if your application experiences an abnormal rise in the rate of HTTP requests or dependency calls that are reported as failed. The anomaly detection uses machine learning algorithms and occurs in near real time, therefore there\'s no need to define a frequency for this signal.<br/></br/>To help you triage and diagnose the problem, an analysis of the characteristics of the failures and related telemetry is provided with the detection. This feature works for any app, hosted in the cloud or on your own servers, that generates request or dependency telemetry - for example, if you have a worker role that calls <a class="ext-smartDetecor-link" href=\\"https://docs.microsoft.com/azure/application-insights/app-insights-api-custom-events-metrics#trackrequest\\" target=\\"_blank\\">TrackRequest()</a> or <a class="ext-smartDetecor-link" href=\\"https://docs.microsoft.com/azure/application-insights/app-insights-api-custom-events-metrics#trackdependency\\" target=\\"_blank\\">TrackDependency()</a>.<br/><br/><a class="ext-smartDetecor-link" href=\\"https://docs.microsoft.com/azure/azure-monitor/app/proactive-failure-diagnostics\\" target=\\"_blank\\">Learn more about Failure Anomalies</a><br><br><b>A note about your data privacy:</b><br><br>The service is entirely automatic and only you can see these notifications. <a class=\\"ext-smartDetecor-link\\" href=\\"https://docs.microsoft.com/en-us/azure/azure-monitor/app/data-retention-privacy\\" target=\\"_blank\\">Read more about data privacy</a><br><br>Smart Alerts conditions can\'t be edited or added for now.'
      id: 'FailureAnomaliesDetector'
      name: 'Failure Anomalies'
      supportedResourceTypes: [
        'ApplicationInsights'
      ]
    }
    frequency: 'PT1M'
    scope: [
      components_clemens_externalid
    ]
    severity: 'Sev3'
    state: 'Enabled'
  }
}

resource smartdetectoralertrules_failure_anomalies_clemens_api_name_resource 'microsoft.alertsmanagement/smartdetectoralertrules@2019-06-01' = {
  location: 'global'
  name: smartdetectoralertrules_failure_anomalies_clemens_api_name
  properties: {
    actionGroups: {
      groupIds: [
        actionGroups_Application_Insights_Smart_Detection_name_resource.id
      ]
    }
    description: 'Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls.'
    detector: {
      description: 'Detects if your application experiences an abnormal rise in the rate of HTTP requests or dependency calls that are reported as failed. The anomaly detection uses machine learning algorithms and occurs in near real time, therefore there\'s no need to define a frequency for this signal.<br/></br/>To help you triage and diagnose the problem, an analysis of the characteristics of the failures and related telemetry is provided with the detection. This feature works for any app, hosted in the cloud or on your own servers, that generates request or dependency telemetry - for example, if you have a worker role that calls <a class="ext-smartDetecor-link" href=\\"https://docs.microsoft.com/azure/application-insights/app-insights-api-custom-events-metrics#trackrequest\\" target=\\"_blank\\">TrackRequest()</a> or <a class="ext-smartDetecor-link" href=\\"https://docs.microsoft.com/azure/application-insights/app-insights-api-custom-events-metrics#trackdependency\\" target=\\"_blank\\">TrackDependency()</a>.<br/><br/><a class="ext-smartDetecor-link" href=\\"https://docs.microsoft.com/azure/azure-monitor/app/proactive-failure-diagnostics\\" target=\\"_blank\\">Learn more about Failure Anomalies</a><br><br><b>A note about your data privacy:</b><br><br>The service is entirely automatic and only you can see these notifications. <a class=\\"ext-smartDetecor-link\\" href=\\"https://docs.microsoft.com/en-us/azure/azure-monitor/app/data-retention-privacy\\" target=\\"_blank\\">Read more about data privacy</a><br><br>Smart Alerts conditions can\'t be edited or added for now.'
      id: 'FailureAnomaliesDetector'
      name: 'Failure Anomalies'
      supportedResourceTypes: [
        'ApplicationInsights'
      ]
    }
    frequency: 'PT1M'
    scope: [
      components_clemens_api_externalid
    ]
    severity: 'Sev3'
    state: 'Enabled'
  }
}

resource smartdetectoralertrules_failure_anomalies_clemens_go_name_resource 'microsoft.alertsmanagement/smartdetectoralertrules@2019-06-01' = {
  location: 'global'
  name: smartdetectoralertrules_failure_anomalies_clemens_go_name
  properties: {
    actionGroups: {
      groupIds: [
        actionGroups_Application_Insights_Smart_Detection_name_resource.id
      ]
    }
    description: 'Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls.'
    detector: {
      description: 'Detects if your application experiences an abnormal rise in the rate of HTTP requests or dependency calls that are reported as failed. The anomaly detection uses machine learning algorithms and occurs in near real time, therefore there\'s no need to define a frequency for this signal.<br/></br/>To help you triage and diagnose the problem, an analysis of the characteristics of the failures and related telemetry is provided with the detection. This feature works for any app, hosted in the cloud or on your own servers, that generates request or dependency telemetry - for example, if you have a worker role that calls <a class="ext-smartDetecor-link" href=\\"https://docs.microsoft.com/azure/application-insights/app-insights-api-custom-events-metrics#trackrequest\\" target=\\"_blank\\">TrackRequest()</a> or <a class="ext-smartDetecor-link" href=\\"https://docs.microsoft.com/azure/application-insights/app-insights-api-custom-events-metrics#trackdependency\\" target=\\"_blank\\">TrackDependency()</a>.<br/><br/><a class="ext-smartDetecor-link" href=\\"https://docs.microsoft.com/azure/azure-monitor/app/proactive-failure-diagnostics\\" target=\\"_blank\\">Learn more about Failure Anomalies</a><br><br><b>A note about your data privacy:</b><br><br>The service is entirely automatic and only you can see these notifications. <a class=\\"ext-smartDetecor-link\\" href=\\"https://docs.microsoft.com/en-us/azure/azure-monitor/app/data-retention-privacy\\" target=\\"_blank\\">Read more about data privacy</a><br><br>Smart Alerts conditions can\'t be edited or added for now.'
      id: 'FailureAnomaliesDetector'
      name: 'Failure Anomalies'
      supportedResourceTypes: [
        'ApplicationInsights'
      ]
    }
    frequency: 'PT1M'
    scope: [
      components_clemens_go_externalid
    ]
    severity: 'Sev3'
    state: 'Enabled'
  }
}

resource smartdetectoralertrules_failure_anomalies_clemens_web_name_resource 'microsoft.alertsmanagement/smartdetectoralertrules@2019-06-01' = {
  location: 'global'
  name: smartdetectoralertrules_failure_anomalies_clemens_web_name
  properties: {
    actionGroups: {
      groupIds: [
        actionGroups_Application_Insights_Smart_Detection_name_resource.id
      ]
    }
    description: 'Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls.'
    detector: {
      description: 'Detects if your application experiences an abnormal rise in the rate of HTTP requests or dependency calls that are reported as failed. The anomaly detection uses machine learning algorithms and occurs in near real time, therefore there\'s no need to define a frequency for this signal.<br/></br/>To help you triage and diagnose the problem, an analysis of the characteristics of the failures and related telemetry is provided with the detection. This feature works for any app, hosted in the cloud or on your own servers, that generates request or dependency telemetry - for example, if you have a worker role that calls <a class="ext-smartDetecor-link" href=\\"https://docs.microsoft.com/azure/application-insights/app-insights-api-custom-events-metrics#trackrequest\\" target=\\"_blank\\">TrackRequest()</a> or <a class="ext-smartDetecor-link" href=\\"https://docs.microsoft.com/azure/application-insights/app-insights-api-custom-events-metrics#trackdependency\\" target=\\"_blank\\">TrackDependency()</a>.<br/><br/><a class="ext-smartDetecor-link" href=\\"https://docs.microsoft.com/azure/azure-monitor/app/proactive-failure-diagnostics\\" target=\\"_blank\\">Learn more about Failure Anomalies</a><br><br><b>A note about your data privacy:</b><br><br>The service is entirely automatic and only you can see these notifications. <a class=\\"ext-smartDetecor-link\\" href=\\"https://docs.microsoft.com/en-us/azure/azure-monitor/app/data-retention-privacy\\" target=\\"_blank\\">Read more about data privacy</a><br><br>Smart Alerts conditions can\'t be edited or added for now.'
      id: 'FailureAnomaliesDetector'
      name: 'Failure Anomalies'
      supportedResourceTypes: [
        'ApplicationInsights'
      ]
    }
    frequency: 'PT1M'
    scope: [
      components_clemens_web_externalid
    ]
    severity: 'Sev3'
    state: 'Enabled'
  }
}

resource profiles_clemens_name_profiles_clemens_name 'Microsoft.Cdn/profiles/endpoints@2020-09-01' = {
  location: 'WestUs'
  name: '${profiles_clemens_name_resource.name}/${profiles_clemens_name}'
  properties: {
    contentTypesToCompress: [
      'application/eot'
      'application/font'
      'application/font-sfnt'
      'application/javascript'
      'application/json'
      'application/opentype'
      'application/otf'
      'application/pkcs7-mime'
      'application/truetype'
      'application/ttf'
      'application/vnd.ms-fontobject'
      'application/xhtml+xml'
      'application/xml'
      'application/xml+rss'
      'application/x-font-opentype'
      'application/x-font-truetype'
      'application/x-font-ttf'
      'application/x-httpd-cgi'
      'application/x-javascript'
      'application/x-mpegurl'
      'application/x-opentype'
      'application/x-otf'
      'application/x-perl'
      'application/x-ttf'
      'font/eot'
      'font/ttf'
      'font/otf'
      'font/opentype'
      'image/svg+xml'
      'text/css'
      'text/csv'
      'text/html'
      'text/javascript'
      'text/js'
      'text/plain'
      'text/richtext'
      'text/tab-separated-values'
      'text/xml'
      'text/x-script'
      'text/x-component'
      'text/x-java-source'
    ]
    deliveryPolicy: {
      rules: [
        {
          actions: [
            {
              name: 'UrlRedirect'
              parameters: {
                '@odata.type': '#Microsoft.Azure.Cdn.Models.DeliveryRuleUrlRedirectActionParameters'
                customHostname: 'clemens.ms'
                customPath: '/caverace'
                destinationProtocol: 'Https'
                redirectType: 'PermanentRedirect'
              }
            }
          ]
          conditions: [
            {
              name: 'RequestUri'
              parameters: {
                '@odata.type': '#Microsoft.Azure.Cdn.Models.DeliveryRuleRequestUriConditionParameters'
                matchValues: [
                  'caverace.com'
                ]
                negateCondition: false
                operator: 'Contains'
                transforms: [
                  'Lowercase'
                ]
              }
            }
          ]
          name: 'caverace'
          order: 1
        }
        {
          actions: [
            {
              name: 'UrlRedirect'
              parameters: {
                '@odata.type': '#Microsoft.Azure.Cdn.Models.DeliveryRuleUrlRedirectActionParameters'
                customHostname: 'clemens.ms'
                destinationProtocol: 'Https'
                redirectType: 'PermanentRedirect'
              }
            }
          ]
          conditions: [
            {
              name: 'RequestScheme'
              parameters: {
                '@odata.type': '#Microsoft.Azure.Cdn.Models.DeliveryRuleRequestSchemeConditionParameters'
                matchValues: [
                  'HTTPS'
                ]
                negateCondition: true
                operator: 'Equal'
              }
            }
          ]
          name: 'http2https'
          order: 2
        }
        {
          actions: [
            {
              name: 'UrlRedirect'
              parameters: {
                '@odata.type': '#Microsoft.Azure.Cdn.Models.DeliveryRuleUrlRedirectActionParameters'
                customHostname: 'clemens.ms'
                destinationProtocol: 'Https'
                redirectType: 'PermanentRedirect'
              }
            }
          ]
          conditions: [
            {
              name: 'RequestUri'
              parameters: {
                '@odata.type': '#Microsoft.Azure.Cdn.Models.DeliveryRuleRequestUriConditionParameters'
                matchValues: [
                  'www'
                ]
                negateCondition: false
                operator: 'BeginsWith'
                transforms: [
                  'Lowercase'
                ]
              }
            }
          ]
          name: 'www2root'
          order: 3
        }
      ]
    }
    geoFilters: []
    isCompressionEnabled: true
    isHttpAllowed: true
    isHttpsAllowed: true
    originGroups: []
    originHostHeader: 'clemensblog.z6.web.core.windows.net'
    origins: [
      {
        name: 'clemensblog-blob-core-windows-net'
        properties: {
          enabled: true
          hostName: 'clemensblog.z6.web.core.windows.net'
          httpPort: 80
          httpsPort: 443
          originHostHeader: 'clemensblog.blob.core.windows.net'
          priority: 1
          weight: 1000
        }
      }
    ]
    queryStringCachingBehavior: 'IgnoreQueryString'
    urlSigningKeys: []
  }
}

resource vaults_clemens_keyvault_name_clemens 'Microsoft.KeyVault/vaults/keys@2019-09-01' = {
  location: 'westeurope'
  name: '${vaults_clemens_keyvault_name_resource.name}/clemens'
  properties: {
    attributes: {
      enabled: true
      exp: 1620431999
      nbf: 1588723200
    }
  }
}

resource Microsoft_KeyVault_vaults_secrets_vaults_clemens_keyvault_name_clemens 'Microsoft.KeyVault/vaults/secrets@2020-04-01-preview' = {
  location: 'westeurope'
  name: '${vaults_clemens_keyvault_name_resource.name}/clemens'
  properties: {
    attributes: {
      enabled: true
      exp: 1620431999
      nbf: 1588723200
    }
    contentType: 'application/x-pkcs12'
  }
}

resource dnszones_clemens_ms_name_autodiscover 'Microsoft.Network/dnszones/CNAME@2018-05-01' = {
  name: '${dnszones_clemens_ms_name_resource.name}/autodiscover'
  properties: {
    CNAMERecord: {
      cname: 'autodiscover.outlook.com'
    }
    TTL: 3600
    targetResource: {}
  }
}

resource dnszones_caverace_com_name_cdnverify 'Microsoft.Network/dnszones/CNAME@2018-05-01' = {
  name: '${dnszones_caverace_com_name_resource.name}/cdnverify'
  properties: {
    CNAMERecord: {
      cname: 'cdnverify.clemens.azureedge.net'
    }
    TTL: 3600
    targetResource: {}
  }
}

resource Microsoft_Network_dnszones_MX_dnszones_clemens_ms_name 'Microsoft.Network/dnszones/MX@2018-05-01' = {
  name: '${dnszones_clemens_ms_name_resource.name}/@'
  properties: {
    MXRecords: [
      {
        exchange: 'clemens-ms.mail.protection.outlook.com'
        preference: 0
      }
    ]
    TTL: 3600
    targetResource: {}
  }
}

resource Microsoft_Network_dnszones_NS_dnszones_caverace_com_name 'Microsoft.Network/dnszones/NS@2018-05-01' = {
  name: '${dnszones_caverace_com_name_resource.name}/@'
  properties: {
    NSRecords: [
      {
        nsdname: 'ns1-01.azure-dns.com.'
      }
      {
        nsdname: 'ns2-01.azure-dns.net.'
      }
      {
        nsdname: 'ns3-01.azure-dns.org.'
      }
      {
        nsdname: 'ns4-01.azure-dns.info.'
      }
    ]
    TTL: 172800
    targetResource: {}
  }
}

resource Microsoft_Network_dnszones_NS_dnszones_clemens_ms_name 'Microsoft.Network/dnszones/NS@2018-05-01' = {
  name: '${dnszones_clemens_ms_name_resource.name}/@'
  properties: {
    NSRecords: [
      {
        nsdname: 'ns1-07.azure-dns.com.'
      }
      {
        nsdname: 'ns2-07.azure-dns.net.'
      }
      {
        nsdname: 'ns3-07.azure-dns.org.'
      }
      {
        nsdname: 'ns4-07.azure-dns.info.'
      }
    ]
    TTL: 172800
    targetResource: {}
  }
}

resource Microsoft_Network_dnszones_SOA_dnszones_caverace_com_name 'Microsoft.Network/dnszones/SOA@2018-05-01' = {
  name: '${dnszones_caverace_com_name_resource.name}/@'
  properties: {
    SOARecord: {
      email: 'azuredns-hostmaster.microsoft.com'
      expireTime: 2419200
      host: 'ns1-01.azure-dns.com.'
      minimumTTL: 300
      refreshTime: 3600
      retryTime: 300
      serialNumber: 1
    }
    TTL: 3600
    targetResource: {}
  }
}

resource Microsoft_Network_dnszones_SOA_dnszones_clemens_ms_name 'Microsoft.Network/dnszones/SOA@2018-05-01' = {
  name: '${dnszones_clemens_ms_name_resource.name}/@'
  properties: {
    SOARecord: {
      email: 'azuredns-hostmaster.microsoft.com'
      expireTime: 2419200
      host: 'ns1-07.azure-dns.com.'
      minimumTTL: 300
      refreshTime: 3600
      retryTime: 300
      serialNumber: 1
    }
    TTL: 3600
    targetResource: {}
  }
}

resource Microsoft_Network_dnszones_TXT_dnszones_clemens_ms_name 'Microsoft.Network/dnszones/TXT@2018-05-01' = {
  name: '${dnszones_clemens_ms_name_resource.name}/@'
  properties: {
    TTL: 3600
    TXTRecords: [
      {
        value: [
          'v=spf1 include:spf.protection.outlook.com -all'
        ]
      }
      {
        value: [
          'google-site-verification=WfHDN9lM8jtXeCwmnUw_ahaTTYp3i-glveZhl8PEK_E'
        ]
      }
    ]
    targetResource: {}
  }
}

resource storageAccounts_clemensblog_name_default 'Microsoft.Storage/storageAccounts/blobServices@2021-01-01' = {
  name: '${storageAccounts_clemensblog_name_resource.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
}

resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_clemensblog_name_default 'Microsoft.Storage/storageAccounts/fileServices@2021-01-01' = {
  name: '${storageAccounts_clemensblog_name_resource.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
    protocolSettings: {
      smb: {}
    }
  }
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
}

resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_clemensblog_name_default 'Microsoft.Storage/storageAccounts/queueServices@2021-01-01' = {
  name: '${storageAccounts_clemensblog_name_resource.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_clemensblog_name_default 'Microsoft.Storage/storageAccounts/tableServices@2021-01-01' = {
  name: '${storageAccounts_clemensblog_name_resource.name}/default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

resource profiles_clemens_name_profiles_clemens_name_caverace_com 'Microsoft.Cdn/profiles/endpoints/customdomains@2020-09-01' = {
  name: '${profiles_clemens_name_profiles_clemens_name.name}/caverace-com'
  properties: {
    hostName: 'caverace.com'
  }
  dependsOn: [
    profiles_clemens_name_resource
  ]
}

resource profiles_clemens_name_profiles_clemens_name_profiles_clemens_name_ms 'Microsoft.Cdn/profiles/endpoints/customdomains@2020-09-01' = {
  name: '${profiles_clemens_name_profiles_clemens_name.name}/${profiles_clemens_name}-ms'
  properties: {
    hostName: 'clemens.ms'
  }
  dependsOn: [
    profiles_clemens_name_resource
  ]
}

resource profiles_clemens_name_profiles_clemens_name_www_caverace_com 'Microsoft.Cdn/profiles/endpoints/customdomains@2020-09-01' = {
  name: '${profiles_clemens_name_profiles_clemens_name.name}/www-caverace-com'
  properties: {
    hostName: 'www.caverace.com'
  }
  dependsOn: [
    profiles_clemens_name_resource
  ]
}

resource profiles_clemens_name_profiles_clemens_name_www_profiles_clemens_name_ms 'Microsoft.Cdn/profiles/endpoints/customdomains@2020-09-01' = {
  name: '${profiles_clemens_name_profiles_clemens_name.name}/www-${profiles_clemens_name}-ms'
  properties: {
    hostName: 'www.clemens.ms'
  }
  dependsOn: [
    profiles_clemens_name_resource
  ]
}

resource profiles_clemens_name_profiles_clemens_name_profiles_clemens_name_blog_blob_core_windows_net 'Microsoft.Cdn/profiles/endpoints/origins@2020-09-01' = {
  name: '${profiles_clemens_name_profiles_clemens_name.name}/${profiles_clemens_name}blog-blob-core-windows-net'
  properties: {
    enabled: true
    hostName: 'clemensblog.z6.web.core.windows.net'
    httpPort: 80
    httpsPort: 443
    originHostHeader: 'clemensblog.blob.core.windows.net'
    priority: 1
    weight: 1000
  }
  dependsOn: [
    profiles_clemens_name_resource
  ]
}

resource Microsoft_Network_dnszones_A_dnszones_caverace_com_name 'Microsoft.Network/dnszones/A@2018-05-01' = {
  name: '${dnszones_caverace_com_name_resource.name}/@'
  properties: {
    TTL: 3600
    targetResource: {
      id: profiles_clemens_name_profiles_clemens_name.id
    }
  }
}

resource Microsoft_Network_dnszones_A_dnszones_clemens_ms_name 'Microsoft.Network/dnszones/A@2018-05-01' = {
  name: '${dnszones_clemens_ms_name_resource.name}/@'
  properties: {
    TTL: 3600
    targetResource: {
      id: profiles_clemens_name_profiles_clemens_name.id
    }
  }
}

resource Microsoft_Network_dnszones_AAAA_dnszones_caverace_com_name 'Microsoft.Network/dnszones/AAAA@2018-05-01' = {
  name: '${dnszones_caverace_com_name_resource.name}/@'
  properties: {
    TTL: 3600
    targetResource: {
      id: profiles_clemens_name_profiles_clemens_name.id
    }
  }
}

resource Microsoft_Network_dnszones_AAAA_dnszones_clemens_ms_name 'Microsoft.Network/dnszones/AAAA@2018-05-01' = {
  name: '${dnszones_clemens_ms_name_resource.name}/@'
  properties: {
    TTL: 3600
    targetResource: {
      id: profiles_clemens_name_profiles_clemens_name.id
    }
  }
}

resource dnszones_caverace_com_name_www 'Microsoft.Network/dnszones/CNAME@2018-05-01' = {
  name: '${dnszones_caverace_com_name_resource.name}/www'
  properties: {
    TTL: 3600
    targetResource: {
      id: profiles_clemens_name_profiles_clemens_name.id
    }
  }
}

resource dnszones_clemens_ms_name_www 'Microsoft.Network/dnszones/CNAME@2018-05-01' = {
  name: '${dnszones_clemens_ms_name_resource.name}/www'
  properties: {
    TTL: 3600
    targetResource: {
      id: profiles_clemens_name_profiles_clemens_name.id
    }
  }
}

resource storageAccounts_clemensblog_name_default_web 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-01-01' = {
  name: '${storageAccounts_clemensblog_name_default.name}/$web'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_clemensblog_name_resource
  ]
}

resource storageAccounts_clemensblog_name_default_azure_webjobs_hosts 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-01-01' = {
  name: '${storageAccounts_clemensblog_name_default.name}/azure-webjobs-hosts'
  properties: {
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccounts_clemensblog_name_resource
  ]
}

resource storageAccounts_clemensblog_name_default_clemens_apia562 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-01-01' = {
  name: '${Microsoft_Storage_storageAccounts_fileServices_storageAccounts_clemensblog_name_default.name}/clemens-apia562'
  properties: {
    accessTier: 'TransactionOptimized'
    enabledProtocols: 'SMB'
    shareQuota: 5120
  }
  dependsOn: [
    storageAccounts_clemensblog_name_resource
  ]
}