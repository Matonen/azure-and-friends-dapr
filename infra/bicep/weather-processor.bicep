param env string

param solution string

param location string

param caeId string

param weatherProcessorImage string

resource weatherProcessor 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'ca-${solution}-weather-proc-${env}'
  location: location
  properties: {
    environmentId: caeId
    configuration: {
      dapr: {
        enabled: true
        appId: 'weather-processor'
        enableApiLogging: true
        appPort: 8080
        appProtocol: 'http'
      }
    }
    template: {
      containers: [
        {
          name: 'weather-processor'
          image: weatherProcessorImage
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
    workloadProfileName: 'Consumption'
  }
}
