using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class UserInsertRequest
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Email { get; set; }
        public string Username { get; set; }
        public string PhoneNumber { get; set; }
        public string? ProfileImageBase64 { get; set; } = null;
        public string Password { get; set; }
        public string PasswordConfirm { get; set; }
        public int CityId { get; set; }
    }
}
