using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.ReservationStateMachine;
using CoWorkHub.Services.Services;
using CoWorkHub.Worker;
using DotNetEnv;
using Mapster;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

var builder = Host.CreateApplicationBuilder(args);

// eksplicitno učitavanje environment varijabli iz Docker-a
builder.Configuration.AddEnvironmentVariables();

Env.Load();

// DbContext
builder.Services.AddDbContext<_210095Context>(options =>
{
    // U Dockeru koristi env varijablu, fallback na appsettings
    var connStr = builder.Configuration.GetConnectionString("CoWorkHubConnection");
    Console.WriteLine($"Using connection string: {connStr}");
    options.UseSqlServer(connStr);
});

// Mapster
var mapsterConfig = new TypeAdapterConfig();
builder.Services.AddSingleton(mapsterConfig);
builder.Services.AddSingleton<IMapper, ServiceMapper>();

builder.Services.AddSingleton<ICurrentUserService, WorkerCurrentUserService>();

// Servisi
builder.Services.AddScoped<IReservationService, ReservationService>();

// State machines – Reservation
builder.Services.AddTransient<BaseReservationState>();
builder.Services.AddTransient<InitialReservationState>();
builder.Services.AddTransient<PendingReservationState>();
builder.Services.AddTransient<ConfirmedReservationState>();
builder.Services.AddTransient<CanceledReservationiState>();
builder.Services.AddTransient<CompletedReservationiState>();

// Worker
builder.Services.AddHostedService<ReservationWorker>();

var host = builder.Build();
host.Run();
