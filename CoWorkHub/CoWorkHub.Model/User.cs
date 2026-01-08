using System;
using System.Collections.Generic;
using System.Text;
using System.Text.Json.Serialization;

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
        [JsonIgnore]
        public byte[]? ProfileImage { get; set; }
        public string? ProfileImageBase64 { get; set; }
        public int CityId { get; set; }
        public bool IsActive { get; set; }
        public bool? IsDeleted { get; set; } = false;
        public DateTime CreatedAt { get; set; }
        public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
    }
}
