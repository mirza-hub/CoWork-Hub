using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class DayAvailability
    {
        public DateTime Date { get; set; }
        public bool IsAvailable { get; set; }
        public int TotalAvailable { get; set; }
    }
}
