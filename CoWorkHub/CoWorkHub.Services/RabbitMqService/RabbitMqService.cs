using CoWorkHub.Model.Messages;
using Newtonsoft.Json;
using RabbitMQ.Client;
using System.Text;
using DotNetEnv;

namespace CoWorkHub.Services.RabbitMqService
{
    public class RabbitMqService : IRabbitMqService
    {
        public async Task SendAnEmail(EmailDTO mail)
        {
            Env.Load();

            var hostname = Environment.GetEnvironmentVariable("_rabbitMqHost") ?? "rabbitmq";
            var username = Environment.GetEnvironmentVariable("_rabbitMqUser") ?? "guest";
            var password = Environment.GetEnvironmentVariable("_rabbitMqPassword") ?? "guest";
            var port = int.Parse(Environment.GetEnvironmentVariable("_rabbitMqPort") ?? "5672");

            Console.WriteLine($"{hostname}:{username}:{password}");
            var factory = new ConnectionFactory { HostName = hostname, UserName = username, Password = password, Port = port };
            using var connection = factory.CreateConnection();
            using var channel = connection.CreateModel();

            channel.QueueDeclare(queue: "mail_sending",
                            durable: false,
                            exclusive: false,
                            autoDelete: false,
                            arguments: null
                            );

            var body = Encoding.UTF8.GetBytes(JsonConvert.SerializeObject(mail));

            channel.BasicPublish(exchange: string.Empty,
                                 routingKey: "mail_sending",
                                 basicProperties: null,
                                 body: body);
        }
    }
}
