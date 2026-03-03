using CoWorkHub.Services.RabbitMqService;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace CoWorkHub.Services.BackgroundServices
{
    public class ReservationStatePublisher : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<ReservationStatePublisher> _logger;

        public ReservationStatePublisher(IServiceScopeFactory scopeFactory,
            ILogger<ReservationStatePublisher> logger)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using var scope = _scopeFactory.CreateScope();
                    var rabbitMqService = scope.ServiceProvider.GetRequiredService<IRabbitMqService>();

                    rabbitMqService.SendReservationStateEvent();
                }
                catch (Exception ex)
                {
                    //Console.WriteLine("Error sending ReservationStateEvent: " + ex.Message);
                    _logger.LogError(ex, "Error sending ReservationStateEvent");
                }

                await Task.Delay(TimeSpan.FromSeconds(60), stoppingToken);
            }
        }
    }
}