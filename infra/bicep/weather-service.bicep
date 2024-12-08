param env string

param solution string

param location string

param caeId string

param weatherServiceImage string

resource weatherService 'Microsoft.App/containerApps@2024-03-01' = {
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
          probes: [
            {
              type: 'Startup'
              httpGet: {
                port: 8080
                path: '/healthz/startup'
                scheme: 'HTTP'
              }
            }
            {
              type: 'Readiness'
              httpGet: {
                port: 8080
                path: '/healthz/readiness'
                scheme: 'HTTP'
              }
            }
            {
              type: 'Liveness'
              httpGet: {
                port: 8080
                path: '/healthz/liveness'
                scheme: 'HTTP'
              }
            }
          ]
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
