using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class VerifyResetCode
    {
        public string Email { get; set; } = null!;
        public string Code { get; set; } = null!;
    }
}
