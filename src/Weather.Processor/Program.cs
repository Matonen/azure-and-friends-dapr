using Dapr.Client;
using Grpc.Core;
using Weather.Service.Grp;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddGrpcClient<WeatherService.WeatherServiceClient>(o =>
{
    o.Address = new Uri("http://localhost:" + builder.Configuration.GetValue<string>("DAPR_GRPC_PORT"));
});

builder.Services.AddSingleton(new DaprClientBuilder().Build());

builder.Services.AddHealthChecks();

var app = builder.Build();

app.MapHealthChecks("/healthz/startup");
app.MapHealthChecks("/healthz/readiness");
app.MapHealthChecks("/healthz/liveness");

app.MapPost("/hurricanes", async (Hurricane hurricane, WeatherService.WeatherServiceClient weatherClient, DaprClient daprClient) =>
{
    var response = await weatherClient.GetCurrentWeatherAsync(new GetCurrentWeatherRequest { City = hurricane.City },
       new Metadata
       {
            { "dapr-app-id", "weather-service" }
       });

    await daprClient.InvokeBindingAsync("hurricane-alerts", "create", new HurricaneAlert
    {
        Message = $"Hurricane Warning for {hurricane.City}! Stay safe and take necessary precautions!",
        HurricaneName = "JYP",
        City = hurricane.City,
        Category = hurricane.Category,
        Temperature = response.Temperature,
    });
    return Results.Ok();
});

app.Run();

public class Hurricane()
{
    public required string City { get; set; }

    public int Category { get; set; }
}

public class HurricaneAlert()
{
    public required string City { get; set; }

    public int Category { get; set; }

    public double Temperature { get; set; }

    public required string HurricaneName { get; set; }

    public required string Message { get; set; }
}