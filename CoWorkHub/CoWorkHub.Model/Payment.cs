using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class Payment
    {
        public int PaymentId { get; set; }
        public int ReservationId { get; set; }
        public int PaymentMethodId { get; set; }
        public DateTime PaymentDate { get; set; }
        public decimal? Discount { get; set; }
        public decimal TotalPaymentAmount { get; set; }
        public string StateMachine { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
    }
}
