using CoWorkHub.Services.Interfaces;

namespace CoWorkHub.Worker
{
    public class ReservationWorker : BackgroundService
    {
        private readonly ILogger<ReservationWorker> _logger;
        private readonly IServiceScopeFactory _scopeFactory;

        public ReservationWorker(ILogger<ReservationWorker> logger, IServiceScopeFactory scopeFactory)
        {
            _logger = logger;
            _scopeFactory = scopeFactory;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("ReservationWorker STARTED");

            using var scope2 = _scopeFactory.CreateScope();
            var configuration = scope2.ServiceProvider.GetRequiredService<IConfiguration>();
            var connStr = configuration.GetConnectionString("CoWorkHubConnection"); // ili kako se zove tvoj connection string
            _logger.LogInformation("Using connection string: {ConnStr}", connStr);
            Console.WriteLine($"Connection string: {Environment.GetEnvironmentVariable("ConnectionStrings__CoWorkHubConnection")}");


            while (!stoppingToken.IsCancellationRequested)
            {
                _logger.LogInformation("ReservationWorker TICK");

                using var scope = _scopeFactory.CreateScope();
                var reservationService = scope.ServiceProvider.GetRequiredService<IReservationService>();

                await reservationService.HandleReservationStates();

                await Task.Delay(TimeSpan.FromMinutes(2), stoppingToken);
            }
        }
    }
}
