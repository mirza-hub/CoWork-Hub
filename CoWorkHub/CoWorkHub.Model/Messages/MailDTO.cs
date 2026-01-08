
using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Messages
{
    public class EmailDTO
    {
        public string EmailTo { get; set; }
        public string ReceiverName { get; set; }
        public string Subject { get; set; }
        public string Message { get; set; }
    }
}
