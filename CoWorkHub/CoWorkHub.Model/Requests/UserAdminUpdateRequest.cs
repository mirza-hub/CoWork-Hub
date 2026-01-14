using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class UserAdminUpdateRequest
    {
        public string? ProfileImageBase64 { get; set; }
        public bool? IsActive { get; set; }
        public List<int>? RolesId { get; set; }
    }
}
