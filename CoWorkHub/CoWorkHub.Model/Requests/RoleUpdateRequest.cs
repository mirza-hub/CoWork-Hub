using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class RoleUpdateRequest
    {
        public string RoleName { get; set; } = null!;
        public string? Description { get; set; }
    }
}
