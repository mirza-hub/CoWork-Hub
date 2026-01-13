using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? ReservationId { get; set; }
        public int? SpaceUnitId { get; set; }
        public byte? RatingFrom { get; set; }
        public byte? RatingTo { get; set; }
        public DateTime? CreatedFrom { get; set; }
        public DateTime? CreatedTo { get; set; }
        public bool IncludeReservation { get; set; } = false;
        public bool IncludeReservationSpaceUnit { get; set; } = false;
    }
}
