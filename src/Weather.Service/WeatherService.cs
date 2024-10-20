using System.Globalization;
using AngleSharp;
using Google.Protobuf.WellKnownTypes;
using Grpc.Core;
using Weather.Service.Grp;

namespace Weather.Service;

public class WeatherService(ILogger<WeatherService> logger, TimeProvider timeProvider) : Grp.WeatherService.WeatherServiceBase
{
    private readonly ILogger<WeatherService> _logger = logger;

    public override async Task<GetCurrentWeatherResponse> GetCurrentWeather(GetCurrentWeatherRequest request,
        ServerCallContext context)
    {
        var browsingContext = BrowsingContext.New(Configuration.Default.WithDefaultLoader());
        var document = await browsingContext.OpenAsync("http://weather.jyu.fi");
        var temperatureElement = document.QuerySelector("#table-a > tbody > tr:nth-child(1) > td:nth-child(2)");
        var temperature = double.Parse(temperatureElement?.TextContent.Replace("\u00b0C", "").Trim() ?? "-273.15",
            CultureInfo.InvariantCulture);
        return new GetCurrentWeatherResponse
        {
            Temperature = temperature,
            Timestamp = timeProvider.GetUtcNow().ToTimestamp()
        };
    }
}