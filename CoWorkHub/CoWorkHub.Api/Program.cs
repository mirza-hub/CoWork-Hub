using CoWorkHub.Api.Filters;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Logging;
using CoWorkHub.Services.Seed;
using CoWorkHub.Services.Services;
using CoWorkHub.Services.WorkingSpaceStateMachine;
using Mapster;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<ICountryService, CountryService>();
builder.Services.AddTransient<ICityService, CityService>();
builder.Services.AddTransient<IResourcesService, ResourcesService>();
builder.Services.AddTransient<IWorkingSpaceService, WorkingSpaceService>();
builder.Services.AddTransient<IUserService, UserService>();


//state machine
builder.Services.AddTransient<BaseWorkingSpaceState>();
builder.Services.AddTransient<InitialWorkingSpaceState>();
builder.Services.AddTransient<DraftWorkingSpaceState>();
builder.Services.AddTransient<ActiveWorkingSpaceState>();
builder.Services.AddTransient<HiddenWorkingSpaceState>();
builder.Services.AddTransient<MaintenanceWorkingSpaceState>();
builder.Services.AddTransient<DeletedWorkingSpaceState>();

builder.Services.AddScoped<IPasswordService, PasswordService>();

builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var connectionString = builder.Configuration.GetConnectionString("CoWorkHubConnection");
builder.Services.AddDbContext<_210095Context>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddMapster();

var app = builder.Build();

// Starting the seeding process on application startup
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<_210095Context>();
    var passwordService = scope.ServiceProvider.GetRequiredService<IPasswordService>();

    DataSeeder.Seed(context, passwordService);
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<_210095Context>();
    dataContext.Database.Migrate();
}

app.Run();
