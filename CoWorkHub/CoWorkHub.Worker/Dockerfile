# Stage 1: Base image for runtime
FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

# Stage 2: Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src

# Kopiramo samo csproj fajl da bi restore bio brži
COPY CoWorkHub.Worker/CoWorkHub.Worker.csproj ./CoWorkHub.Worker/
RUN dotnet restore ./CoWorkHub.Worker/CoWorkHub.Worker.csproj

# Kopiramo ostatak projekta
COPY CoWorkHub.Worker/. ./CoWorkHub.Worker/

WORKDIR /src/CoWorkHub.Worker
RUN dotnet build CoWorkHub.Worker.csproj -c $BUILD_CONFIGURATION -o /app/build

# Stage 3: Publish stage
FROM build AS publish
ARG BUILD_CONFIGURATION=Release
WORKDIR /src/CoWorkHub.Worker
RUN dotnet publish CoWorkHub.Worker.csproj -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

# Stage 4: Final image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CoWorkHub.Worker.dll"]
