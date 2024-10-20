FROM mcr.microsoft.com/dotnet/aspnet:8.0-jammy-chiseled AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["src/Weather.Service/Weather.Service.csproj", "src/Weather.Service/"]
RUN dotnet restore "src/Weather.Service/Weather.Service.csproj"
COPY . .
WORKDIR "/src/src/Weather.Service"
RUN dotnet build "Weather.Service.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Weather.Service.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Weather.Service.dll"]
