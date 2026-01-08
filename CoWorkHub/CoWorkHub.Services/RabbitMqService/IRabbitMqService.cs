using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.RabbitMqService
{
    public interface IRabbitMqService
    {
        Task SendAnEmail(Model.Messages.EmailDTO mail);
    }
}
