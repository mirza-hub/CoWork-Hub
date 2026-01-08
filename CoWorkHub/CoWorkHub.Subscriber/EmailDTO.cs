using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Subscriber
{
    public class EmailDTO
    {
        public string EmailTo { get; set; }
        public string ReceiverName { get; set; }
        public string Subject { get; set; }
        public string Message { get; set; }
    }
}
