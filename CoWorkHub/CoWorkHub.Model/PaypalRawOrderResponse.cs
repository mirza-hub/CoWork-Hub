using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class PaypalRawOrderResponse
    {
        public string Id { get; set; }
        public string Status { get; set; }
        public List<PaypalLink> Links { get; set; }
    }
}
