using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class PaymentMethodSearchObject : BaseSearchObject
    {
        public string? PaymentMethodNameGTE { get; set; } = null!;
    }
}
