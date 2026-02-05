FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

COPY ["CoWorkHub.Worker/CoWorkHub.Worker.csproj", "CoWorkHub.Worker/"]
COPY ["CoWorkHub.Model/CoWorkHub.Model.csproj", "CoWorkHub.Model/"]
COPY ["CoWorkHub.Services/CoWorkHub.Services.csproj", "CoWorkHub.Services/"]

RUN dotnet restore "CoWorkHub.Worker/CoWorkHub.Worker.csproj"

COPY . .

WORKDIR /src/CoWorkHub.Worker
RUN dotnet build "CoWorkHub.Worker.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
WORKDIR /src/CoWorkHub.Worker
RUN dotnet publish "CoWorkHub.Worker.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CoWorkHub.Worker.dll"]
