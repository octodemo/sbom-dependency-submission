param containerImage string
param containerRegistry string
param containerRegistryUsername string
@secure()
param containerRegistryPassword string
param containerPort string = '8080'

param servicePlanName string

param githubRef string
param githubRepository string

param environmentName string
param location string = resourceGroup().location

var siteName = 'bookstore-${uniqueString(resourceGroup().id, githubRef, environmentName)}'

resource website 'Microsoft.Web/sites@2021-03-01' = {
  name: siteName
  kind: 'app,linux,container'
  tags: {
    repository: githubRepository
    ref: githubRef
    environment: environmentName
  }
  location: location

  properties: {
    serverFarmId: servicePlanName
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerImage}'
      healthCheckPath: '/status'
    }
  }

  resource appSettings 'config@2021-03-01' = {
    name: 'appsettings'
    properties: {
      WEBSITES_PORT: containerPort
      WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'true'
      DOCKER_REGISTRY_SERVER_PASSWORD: containerRegistryPassword
      DOCKER_REGISTRY_SERVER_USERNAME: containerRegistryUsername
      DOCKER_REGISTRY_SERVER_URL: containerRegistry
    }
  }
}

output url string = 'https://${siteName}.azurewebsites.net'
