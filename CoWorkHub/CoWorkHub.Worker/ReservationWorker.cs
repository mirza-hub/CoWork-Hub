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
