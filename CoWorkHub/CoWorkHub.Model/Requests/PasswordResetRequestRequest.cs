using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class PasswordResetRequestRequest
    {
        public string Email { get; set; } = null!;
    }
}
