param env string

param solution string

param location string

param weatherApiImage string

param caeId string

resource weatherApi 'Microsoft.App/containerApps@2024-03-01' = {
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
