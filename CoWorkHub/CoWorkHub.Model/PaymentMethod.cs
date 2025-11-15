using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class PaymentMethod
    {
        public int PaymentMethodId { get; set; }
        public string PaymentMethodName { get; set; } = null!;
        public bool IsDeleted { get; set; } = false;
    }
}
