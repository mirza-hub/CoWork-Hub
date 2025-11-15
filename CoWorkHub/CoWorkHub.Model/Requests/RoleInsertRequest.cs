using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class RoleInsertRequest
    {
        public string RoleName { get; set; } = null!;
        public string? Description { get; set; }
    }
}
