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

resource hurricanesEventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  name: 'hurricanes'
  parent: eventHubNamespace
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
  }
}

resource hurricaneAlertsEventHub 'Microsoft.EventHub/namespaces/eventhubs@2024-01-01' = {
  name: 'hurricane-alerts'
  parent: eventHubNamespace
  properties: {
    messageRetentionInDays: 1
    partitionCount: 1
  }
}
