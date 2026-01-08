using CoWorkHub.Api.Auth;
using CoWorkHub.Api.Filters;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.RabbitMqService;
using CoWorkHub.Services.ReservationStateMachine;
using CoWorkHub.Services.Seed;
using CoWorkHub.Services.Services;
using CoWorkHub.Services.WorkingSpaceStateMachine;
using FluentValidation;
using Mapster;
using MapsterMapper;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<ICountryService, CountryService>();
builder.Services.AddTransient<ICityService, CityService>();
builder.Services.AddTransient<IResourcesService, ResourcesService>();
builder.Services.AddTransient<IWorkingSpaceService, WorkingSpaceService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<IWorkspaceTypeService, WorkspaceTypeService>();
builder.Services.AddTransient<IPaymentMethodService, PaymentMethodService>();
builder.Services.AddTransient<IReservationService, ReservationService>();
builder.Services.AddTransient<IReviewService, ReviewService>();
builder.Services.AddTransient<ISpaceUnitService, SpaceUnitService>();
builder.Services.AddTransient<ISpaceUnitResourceService, SpaceUnitResourceService>();
builder.Services.AddTransient<ISpaceUnitImageService, SpaceUnitImageService>();
builder.Services.AddTransient<IPaymentService, PaymentService>();

builder.Services.AddHttpClient<IGeoLocationService, GeoLocationService>();

//state machines
//Reservation
builder.Services.AddTransient<BaseReservationState>();
builder.Services.AddTransient<InitialReservationState>();
builder.Services.AddTransient<PendingReservationState>();
builder.Services.AddTransient<ConfirmedReservationState>();
builder.Services.AddTransient<CanceledReservationiState>();
builder.Services.AddTransient<CompletedReservationiState>();

 //SpaceUnit
builder.Services.AddTransient<BaseSpaceUnitState>();
builder.Services.AddTransient<InitialSpaceUnitState>();
builder.Services.AddTransient<DraftSpaceUnitState>();
builder.Services.AddTransient<ActiveSpaceUnitState>();
builder.Services.AddTransient<HiddenSpaceUnitState>();
builder.Services.AddTransient<MaintenanceSpaceUnitState>();
builder.Services.AddTransient<DeletedSpaceUnitState>();

builder.Services.AddScoped<IPasswordService, PasswordService>();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddScoped<IRabbitMqService, RabbitMqService>();
builder.Services.AddScoped<IWorkingSpaceImageService, WorkingSpaceImagesService>();

builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "basicAuth"}
            },
            new string[]{}
    } });

});

//DotNetEnv.Env.Load();

var connectionString = builder.Configuration.GetConnectionString("CoWorkHubConnection");
builder.Services.AddDbContext<_210095Context>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddMapster();
builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

builder.Services.AddHttpContextAccessor();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        policy =>
        {
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        });
});

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

app.UseCors("AllowAll");

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseAuthorization();

app.MapControllers();



using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<_210095Context>();
    dataContext.Database.Migrate();
}

app.Run();
