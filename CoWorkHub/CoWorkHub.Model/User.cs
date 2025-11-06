using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class User
    {
        public int UsersId { get; set; }
        public string FirstName { get; set; } = null!;
        public string LastName { get; set; } = null!;
        public string Email { get; set; } = null!;
        public string Username { get; set; } = null!;
        public string PhoneNumber { get; set; } = null!;
        public string? ProfileImageUrl { get; set; }
        public int CityId { get; set; }
        public int RoleId { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
