targetScope = 'subscription'

param env string

param solution string

param location string = deployment().location

param weatherApiImage string

param weatherServiceImage string

param weatherProcessorImage string

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${solution}-${env}'
  location: location
}

module eventHub 'event-hub.bicep' = {
  name: 'eventHub'
  params: {
    name: 'eh-${solution}-${env}'
    location: location
  }
  scope: rg
}

module cae 'cae.bicep' = {
  name: 'cae'
  params: {
    location: location
    env: env
    solution: solution
  }
  scope: rg
}

module api 'weather-api.bicep' = {
  name: 'weatherApi'
  params: {
    env: env
    solution: solution
    location: location
    weatherApiImage: weatherApiImage
    caeId: cae.outputs.id
  }
  scope: rg
}

module service 'weather-service.bicep' = {
  name: 'weatherService'
  params: {
    env: env
    solution: solution
    location: location
    weatherServiceImage: weatherServiceImage
    caeId: cae.outputs.id
  }
  scope: rg
}

module processor 'weather-processor.bicep' = {
  name: 'weatherProcessor'
  params: {
    env: env
    solution: solution
    location: location
    weatherProcessorImage: weatherProcessorImage
    caeId: cae.outputs.id
  }
  scope: rg
}
