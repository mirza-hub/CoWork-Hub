using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class DayAvailability
    {
        public DateTime Date { get; set; }
        public bool IsAvailable { get; set; }
        public int Capacity { get; set; }
        public int Reserved { get; set; }
        public int Free { get; set; }
    }
}
