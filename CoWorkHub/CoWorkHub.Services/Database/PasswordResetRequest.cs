using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Database
{
    public class PasswordResetRequest : ISoftDeletable
    {
        public int PasswordResetRequestId { get; set; }
        public int UserId { get; set; }
        public string Code { get; set; } = null!;
        public DateTime ExpiresAt { get; set; }
        public bool IsUsed { get; set; } = false;
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public bool IsDeleted { get; set; }
        public DateTime? DeletedAt { get; set; }
        public User User { get; set; } = null!;
    }
}
