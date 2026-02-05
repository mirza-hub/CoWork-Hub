FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY CoWorkHub.Model/ CoWorkHub.Model/
COPY CoWorkHub.Subscriber/ CoWorkHub.Subscriber/

WORKDIR /src/CoWorkHub.Subscriber

RUN dotnet restore
RUN dotnet publish -c Release -o /app

FROM mcr.microsoft.com/dotnet/runtime:8.0 AS runtime
WORKDIR /app
COPY --from=build /app .

ENTRYPOINT ["dotnet", "CoWorkHub.Subscriber.dll"]