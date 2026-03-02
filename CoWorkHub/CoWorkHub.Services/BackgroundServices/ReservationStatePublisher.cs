using CoWorkHub.Services.RabbitMqService;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace CoWorkHub.Services.BackgroundServices
{
    public class ReservationStatePublisher : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;

        public ReservationStatePublisher(IServiceScopeFactory scopeFactory)
        {
            _scopeFactory = scopeFactory;
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
                    Console.WriteLine("Error sending ReservationStateEvent: " + ex.Message);
                }

                await Task.Delay(TimeSpan.FromSeconds(60), stoppingToken);
            }
        }
    }
}