param name string
param location string

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: name
  location: location
  sku: {
    name: 'Basic'
    capacity: 1
  }
}

resource hurricaneWatchesEventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  name: 'hurricane-watches'
  parent: eventHubNamespace
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
  }
}

resource hurricaneWarningsEventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  name: 'hurricane-warnings'
  parent: eventHubNamespace
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
  }
}
