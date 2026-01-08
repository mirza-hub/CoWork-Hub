using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class PaymentSearchObject : BaseSearchObject
    {
        public int? PaymentId { get; set; }
        public int? ReservationId { get; set; }
        public int? PaymentMethodId { get; set; }
        public DateTime? DateFrom { get; set; }
        public DateTime? DateTo { get; set; }
        public decimal? PriceFrom { get; set; }
        public decimal? PriceTo { get; set; }
        public string? StateMachine { get; set; }
    }
}
