using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class UserRole
    {
        public int UserRoleId { get; set; }
        public int UserId { get; set; }
        public int RoleId { get; set; }
        public DateTime? ModifiedAt { get; set; }
        public virtual Role Role { get; set; } = null!;
    }
}
