using DotNetEnv;
using MailKit.Net.Smtp;
using Microsoft.Extensions.Logging;
using MimeKit;

namespace CoWorkHub.Subscriber
{
    public class MailSender
    {
        private readonly ILogger<MailSender> _logger;

        public MailSender(ILogger<MailSender> logger)
        {
            _logger = logger;
        }

        public async Task SendEmail(EmailDTO mailObj)
        {
            if (mailObj == null) return;
            //DotNetEnv.Env.Load();
            //Env.Load();

            string fromAddress = Environment.GetEnvironmentVariable("_fromAddress") ?? "topstvari0@gmail.com";
            string password = Environment.GetEnvironmentVariable("_password") ?? string.Empty;
            string host = Environment.GetEnvironmentVariable("_host") ?? "smtp.gmail.com";
            int port = int.Parse(Environment.GetEnvironmentVariable("_port") ?? "465");
            bool enableSSL = bool.Parse(Environment.GetEnvironmentVariable("_enableSSL") ?? "true");
            string displayName = Environment.GetEnvironmentVariable("_displayName") ?? "no-reply";
            int timeout = int.Parse(Environment.GetEnvironmentVariable("_timeout") ?? "255");
 
            if (password == string.Empty)
            {
                //Console.WriteLine("Šifra je prazna");
                _logger.LogWarning("Šifra je prazna, email se neće poslati");
                return;
            }

            var email = new MimeMessage();

            email.From.Add(new MailboxAddress(displayName, fromAddress));
            email.To.Add(new MailboxAddress(mailObj.ReceiverName, mailObj.EmailTo));

            email.Subject = mailObj.Subject;

            email.Body = new TextPart(MimeKit.Text.TextFormat.Html)
            {
                Text = mailObj.Message
            };

            try
            {
                //Console.WriteLine($"Slanje emaila od {fromAddress} prema {mailObj.EmailTo}, preko porta: {port}, at {DateTime.Now}");
                _logger.LogInformation("Slanje emaila od {FromAddress} prema {ToAddress}, preko porta: {Port}, at {Time}",
                    fromAddress,
                    mailObj.EmailTo,
                    port,
                    DateTime.Now
 );
                using (var smtp = new SmtpClient())
                {
                    await smtp.ConnectAsync(host, port, enableSSL);
                    await smtp.AuthenticateAsync(fromAddress, password);

                    await smtp.SendAsync(email);
                    await smtp.DisconnectAsync(true);
                }
                //Console.WriteLine("Uspjesno poslata poruka");
                _logger.LogInformation("Uspješno poslata poruka");
            }
            catch (Exception ex)
            {
                Console.WriteLine("Greška SA SLANJEM PORUKA!");
                _logger.LogError("Greška SA SLANJEM PORUKA!");
                _logger.LogError(ex.ToString());

                //Console.WriteLine($"Error {ex.Message}");
                return;
            }
        }
    }
}
