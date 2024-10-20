param env string

param solution string

param location string

param weatherApiImage string

param caeId string

resource weatherApi 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'ca-${solution}-weather-api-${env}'
  location: location
  properties: {
    environmentId: caeId
    configuration: {
      ingress: {
        external: true
        transport: 'http'
        targetPort: 8080
        allowInsecure: false
      }
      dapr: {
        enabled: true
        appId: 'weather-api'
        enableApiLogging: true
      }
    }
    template: {
      containers: [
        {
          name: 'weather-api'
          image: weatherApiImage
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
