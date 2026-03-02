using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class NotificationInsertRequest
    {
        public int UserId { get; set; }
        public string Message { get; set; } = null!;
    }
}
