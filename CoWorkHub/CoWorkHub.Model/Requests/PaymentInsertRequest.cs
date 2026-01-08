using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class PaymentInsertRequest
    {
        public int ReservationId { get; set; }
        public int PaymentMethodId { get; set; }
        public decimal? Discount { get; set; } = 0;
        public decimal TotalPaymentAmount { get; set; }
    }
}
