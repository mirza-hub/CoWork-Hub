using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class PaypalCreateOrderResponseDto
    {
        public string Id { get; set; }
        public string Status { get; set; }
        public string ApprovalUrl { get; set; }
    }
}
