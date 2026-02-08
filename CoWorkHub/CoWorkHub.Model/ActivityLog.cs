using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class ActivityLog
    {
        public int ActivityLogId { get; set; }
        public int? UserId { get; set; }
        public string Action { get; set; } = null!;
        public string Entity { get; set; } = null!;
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; }
        public virtual User? User { get; set; } = null!;
    }
}
