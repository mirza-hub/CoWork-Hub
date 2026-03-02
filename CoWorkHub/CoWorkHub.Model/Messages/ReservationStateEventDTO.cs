using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Messages
{
    public class ReservationStateEventDTO
    {
        public DateTime TriggeredAt { get; set; } = DateTime.Now;
    }
}
