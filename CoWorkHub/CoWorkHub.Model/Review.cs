using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class Review
    {
        public int ReviewsId { get; set; }
        public int ReservationId { get; set; }
        public byte Rating { get; set; }
        public string Comment { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
        public virtual Reservation Reservation { get; set; } = null!;
    }
}
