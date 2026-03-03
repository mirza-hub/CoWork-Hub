using CoWorkHub.Model.Messages;
using CoWorkHub.Services.Interfaces;
using DotNetEnv;
using Newtonsoft.Json;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;

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
            var hostname = Environment.GetEnvironmentVariable("_rabbitMqHost") ?? "rabbitmq";
            var username = Environment.GetEnvironmentVariable("_rabbitMqUser") ?? "guest";
            var password = Environment.GetEnvironmentVariable("_rabbitMqPassword") ?? "guest";
            var port = int.Parse(Environment.GetEnvironmentVariable("_rabbitMqPort") ?? "5672");

            var factory = new ConnectionFactory { HostName = hostname, UserName = username, Password = password, Port = port };
            IConnection connection = null;
            IModel channel = null;

            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    _logger.LogInformation("Trying to connect to RabbitMQ...");

                    connection = factory.CreateConnection();
                    channel = connection.CreateModel();

                    _logger.LogInformation("Connected to RabbitMQ!");
                    break;
                }
                catch (Exception ex)
                {
                    _logger.LogWarning("RabbitMQ not ready. Retrying in 5 seconds...");
                    await Task.Delay(5000, stoppingToken);
                }
            }

            channel.QueueDeclare(
                queue: "reservation_state_check",
                durable: false,
                exclusive: false,
                autoDelete: false,
                arguments: null
            );

            var consumer = new EventingBasicConsumer(channel);
            consumer.Received += async (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                var eventObj = JsonConvert.DeserializeObject<ReservationStateEventDTO>(message);

                if (eventObj != null)
                {
                    using var scope = _scopeFactory.CreateScope();
                    var reservationService = scope.ServiceProvider.GetRequiredService<IReservationService>();
                    await reservationService.HandleReservationStates();
                    _logger.LogInformation("Processed ReservationStateEvent at {time}", DateTime.Now);
                }
            };

            channel.BasicConsume(queue: "reservation_state_check", autoAck: true, consumer: consumer);

            while (!stoppingToken.IsCancellationRequested)
            {
                await Task.Delay(1000, stoppingToken);
            }
        }
    }
}
