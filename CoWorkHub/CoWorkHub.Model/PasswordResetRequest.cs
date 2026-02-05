using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class PasswordResetRequest
    {
        public int UserId { get; set; }
        public string Code { get; set; } = null!;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
