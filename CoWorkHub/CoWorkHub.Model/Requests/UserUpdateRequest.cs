using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class UserUpdateRequest
    {
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Username { get; set; }
        public string? ProfileImageBase64 { get; set; }
        public string? Password { get; set; }
        public string? PasswordConfirm { get; set; }
    }
}
