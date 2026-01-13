using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class ReviewInsertRequest
    {
        public int ReservationId { get; set; }
        public byte Rating { get; set; }
        public string Comment { get; set; } = null!;
    }
}
