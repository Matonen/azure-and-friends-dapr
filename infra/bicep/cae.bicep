param env string

param solution string

param location string

resource log 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'log-${solution}-${env}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource st 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  #disable-next-line BCP334
  name: 'st${replace(solution, '-','')}${env}'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: st
  name: 'default'
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'dapr-checkpoints'
}

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  #disable-next-line BCP334
  name: 'eh-${solution}-${env}'
}

resource eventHubNamespaceAccessKey 'Microsoft.EventHub/namespaces/authorizationRules@2024-01-01' existing = {
  parent: eventHubNamespace
  name: 'RootManageSharedAccessKey'
}

resource cae 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: 'cae-${solution}-${env}'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: log.properties.customerId
        sharedKey: log.listKeys().primarySharedKey
      }
    }
    workloadProfiles: [
      {
        name: 'Consumption'
        workloadProfileType: 'Consumption'
      }
    ]
  }
}

resource hurricanesBinding 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = {
  parent: cae
  name: 'hurricanes'
  properties: {
    componentType: 'bindings.azure.eventhubs'
    version: 'v1'
    scopes: ['weather-processor']
    metadata: [
      {
        name: 'consumerGroup'
        value: '$Default'
      }
      {
        name: 'connectionString'
        value: '${eventHubNamespaceAccessKey.listKeys().primaryConnectionString};EntityPath=hurricanes'
      }
      {
        name: 'direction'
        value: 'input'
      }
      //Checkpoint store attributes
      {
        name: 'storageAccountName'
        value: st.name
      }
      {
        name: 'storageAccountKey'
        value: st.listKeys().keys[0].value
      }
      {
        name: 'storageContainerName'
        value: 'dapr-checkpoints'
      }
    ]
  }
}

resource hurricaneAlertsBinding 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = {
  parent: cae
  name: 'hurricane-alerts'
  properties: {
    componentType: 'bindings.azure.eventhubs'
    version: 'v1'
    scopes: ['weather-processor']
    metadata: [
      {
        name: 'connectionString'
        value: '${eventHubNamespaceAccessKey.listKeys().primaryConnectionString};EntityPath=hurricane-alerts'
      }
      {
        name: 'direction'
        value: 'output'
      }
    ]
  }
}

output id string = cae.id
