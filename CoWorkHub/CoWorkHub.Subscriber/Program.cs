using CoWorkHub.Subscriber;
using DotNetEnv;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using static System.Formats.Asn1.AsnWriter;

var serviceCollection = new ServiceCollection();
serviceCollection.AddLogging(config =>
{
    config.AddConsole();
    config.SetMinimumLevel(LogLevel.Information);
});
serviceCollection.AddSingleton<MailSender>(); // MailSender više nije static
var serviceProvider = serviceCollection.BuildServiceProvider();
var logger = serviceProvider.GetRequiredService<ILogger<Program>>();
var mailSender = serviceProvider.GetRequiredService<MailSender>();

var envPath = Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", ".env");

if (File.Exists(envPath))
{
    Env.Load(envPath);
}

//Console.WriteLine("Sleeping to wait for Rabbit");
logger.LogInformation("Sleeping to wait for Rabbit");
Task.Delay(10000).Wait();

Task.Delay(1000).Wait();
logger.LogInformation("Consuming Queue Now");
//Console.WriteLine("Consuming Queue Now");


var hostname = Environment.GetEnvironmentVariable("_rabbitMqHost") ?? "rabbitmq";
var username = Environment.GetEnvironmentVariable("_rabbitMqUser") ?? "guest";
var password = Environment.GetEnvironmentVariable("_rabbitMqPassword") ?? "guest";
var port = int.Parse(Environment.GetEnvironmentVariable("_rabbitMqPort") ?? "5672");

ConnectionFactory factory = new ConnectionFactory() { HostName = hostname, Port = port };
factory.UserName = username;
factory.Password = password;
IConnection conn = factory.CreateConnection();
IModel channel = conn.CreateModel();
channel.QueueDeclare(queue: "mail_sending",
                        durable: false,
                        exclusive: false,
                        autoDelete: false,
                        arguments: null);

var consumer = new EventingBasicConsumer(channel);
consumer.Received += async (model, ea) =>
{
    //Console.WriteLine("Message received!");
    logger.LogInformation("Message received!");
    var body = ea.Body.ToArray();
    var message = Encoding.UTF8.GetString(body);

    logger.LogInformation("Message content: {Message}", message);

    var entity = JsonConvert.DeserializeObject<EmailDTO>(message);
    logger.LogInformation(entity?.EmailTo);
    //Console.WriteLine(entity?.EmailTo);
    if (entity != null)
    {
        //MailSender.SendEmail(entity!);
        await mailSender.SendEmail(entity);
    }
};
channel.BasicConsume(queue: "mail_sending",
                     autoAck: true,
                     consumer: consumer);



Thread.Sleep(Timeout.Infinite);

Console.ReadLine();