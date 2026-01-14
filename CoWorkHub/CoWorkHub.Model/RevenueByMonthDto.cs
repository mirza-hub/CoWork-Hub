using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class RevenueByMonthDto
    {
        public string Month { get; set; } = null!;
        public decimal Revenue { get; set; }
    }
}
