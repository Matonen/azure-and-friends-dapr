using Dapr.Client;
using Grpc.Core;
using Weather.Service.Grp;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddGrpcClient<WeatherService.WeatherServiceClient>(o =>
{
    o.Address = new Uri("http://localhost:" + builder.Configuration.GetValue<string>("DAPR_GRPC_PORT"));
});

builder.Services.AddSingleton(new DaprClientBuilder().Build());

var app = builder.Build();

app.MapPost("/hurricane-watches", async (HurricaneWatch hurricaneWatch, WeatherService.WeatherServiceClient weatherClient, DaprClient daprClient) =>
{
    var response = await weatherClient.GetCurrentWeatherAsync(new GetCurrentWeatherRequest { City = hurricaneWatch.City },
       new Metadata
       {
            { "dapr-app-id", "weather-service" }
       });

    await daprClient.InvokeBindingAsync("hurricane-warnings", "create", new HurricaneWarning
    {
        Message = $"Hurricane Warning for {hurricaneWatch.City}! Stay safe and take necessary precautions!",
        HurricaneName = "JYP",
        City = hurricaneWatch.City,
        Category = hurricaneWatch.Category,
        Temperature = response.Temperature,
    });
    return Results.Ok();
});

app.Run();

public class HurricaneWatch()
{
    public required string City { get; set; }

    public int Category { get; set; }
}

public class HurricaneWarning()
{
    public required string City { get; set; }

    public int Category { get; set; }

    public double Temperature { get; set; }

    public required string HurricaneName { get; set; }

    public required string Message { get; set; }
}