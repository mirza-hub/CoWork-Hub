using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class Notification
    {
        public int NotificationId { get; set; }
        public int UserId { get; set; }
        public string Message { get; set; } = null!;
        public bool IsRead { get; set; } = false;
        public DateTime CreatedAt { get; set; }
        public virtual User User { get; set; } = null!;
    }
}
