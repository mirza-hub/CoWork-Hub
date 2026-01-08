using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class PaymentUpdateRequest
    {
        public decimal? Discount { get; set; }
        public decimal? TotalPaymentAmount { get; set; }
        public string? StateMachine { get; set; } = null!;
    }
}
