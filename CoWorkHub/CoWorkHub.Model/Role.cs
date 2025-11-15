using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class Role
    {
        public int RolesId { get; set; }
        public string RoleName { get; set; } = null!;
        public string? Description { get; set; }
        public bool? IsDeleted { get; set; } = false;
    }
}
