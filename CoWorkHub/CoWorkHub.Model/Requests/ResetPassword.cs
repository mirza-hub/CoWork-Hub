using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class ResetPassword
    {
        public string Email { get; set; } = null!;
        public string NewPassword { get; set; } = null!;
        public string NewPasswordConfirm { get; set; } = null!;
    }
}
