using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class ReservationInsertRequest
    {
        public int SpaceUnitId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime? EndDate { get; set; }
        public int PeopleCount { get; set; } = 1;
    }
}
