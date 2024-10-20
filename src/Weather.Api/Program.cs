using Grpc.Core;
using Weather.Service.Grp;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddGrpcClient<WeatherService.WeatherServiceClient>(o =>
{
    o.Address = new Uri("http://localhost:" + builder.Configuration.GetValue<string>("DAPR_GRPC_PORT"));
});

var app = builder.Build();

app.MapGet("/weather", async (WeatherService.WeatherServiceClient client) =>
{
    var response = await client.GetCurrentWeatherAsync(new GetCurrentWeatherRequest { City = "tre" },
        new Metadata
        {
            { "dapr-app-id", "weather-service" }
        });


    var weather = new CurrentWeather
    (
        response.Timestamp.ToDateTimeOffset(),
        response.Temperature
    );
    return weather;
});

app.Run();

internal record CurrentWeather(DateTimeOffset Timestamp, double Temperature)
{
}