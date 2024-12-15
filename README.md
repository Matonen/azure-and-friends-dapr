# Azure & Friends - Dapr

This repository provides an example codes to build microservices using the Dapr and Azure Container Apps.

## Get Started

Follow these steps to get the project up and running:

### Prerequisites

1. **Install Dapr CLI**: Follow the instructions [here](https://docs.dapr.io/getting-started/install-dapr-cli/).
2. **Install Docker**: Ensure Docker is installed and running on your machine. You can download it from [here](https://www.docker.com/products/docker-desktop).
3. **Install .NET SDK**: Download and install the .NET SDK from [here](https://dotnet.microsoft.com/download).

### Running the solution

1. **Start 3rd party services**:
    ```sh
    docker compose -f ./docker/docker-compose.yaml up
    ```

2. **Run the Multi-App**:
    ```sh
    dapr run -f ./dapr/dapr.yaml
    ```

3. **Access the API**:
    - Weather API: `http://localhost:5123/weather`


### Testing the solution

Add hurricate watch message to `hurricanes` queue:

```json
{ 
    "City": "Tampere",
    "Category": 3
}
```

### Additional Resources

- [Dapr Documentation](https://docs.dapr.io/)
- [Docker Documentation](https://docs.docker.com/)
- [.NET Documentation](https://docs.microsoft.com/en-us/dotnet/)

## Deploy to the Azure

Follow these steps to deploy the solution to Azure.

### Create image

Use following commands to create and push images to docker hub.

Set username:

```sh
export DOCKER_HUB_USERNAME=<your_username>
```

Tag and push images to Docker Hub.

```sh
docker build -t $DOCKER_HUB_USERNAME/dapr-weather-api:latest -f src/Weather.Api/Dockerfile .
docker push $DOCKER_HUB_USERNAME/dapr-weather-api:latest

docker build -t $DOCKER_HUB_USERNAME/dapr-weather-service:latest -f src/Weather.Service/Dockerfile .
docker push $DOCKER_HUB_USERNAME/dapr-weather-service:latest

docker build -t $DOCKER_HUB_USERNAME/dapr-weather-processor:latest -f src/Weather.Processor/Dockerfile .
docker push $DOCKER_HUB_USERNAME/dapr-weather-processor:latest

```

### Deploy Azure Infra

To deploy updates to Azure, follow these steps:

1. Open terminal
2. Log in using your Azure AD credentials: `az login`
3. Go to the directory: `cd infra/bicep`
4. First verify the changes using what-if command: `az deployment sub what-if --subscription {subscription} --location westeurope --template-file main.bicep --parameters {env}.bicepparam`
5. Deploy the changes: `az deployment sub create --subscription {subscription} --location westeurope --template-file main.bicep --parameters {env}.bicepparam`

## Troubleshooting

Here is a list of common problems you might encounter:

### Failed to bind to address

#### Error message

Failed to bind to address http://127.0.0.1:5123 address already in use

#### Solution

List process that uses the port and kill it.

```sh
sudo lsof -i -P | grep LISTEN | grep :5123
kill -9 <PID>
```
