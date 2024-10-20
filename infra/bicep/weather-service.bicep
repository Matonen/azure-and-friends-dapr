param env string

param solution string

param location string

param caeId string

param weatherServiceImage string

resource weatherService 'Microsoft.App/containerApps@2023-05-01' = {
  name: 'ca-${solution}-weather-svc-${env}'
  location: location
  properties: {
    environmentId: caeId
    configuration: {
      dapr: {
        enabled: true
        appId: 'weather-service'
        enableApiLogging: true
        appPort: 8080
        appProtocol: 'grpc'
      }
    }
    template: {
      containers: [
        {
          name: 'weather-service'
          image: weatherServiceImage
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
