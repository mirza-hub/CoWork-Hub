using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class SpaceUnitAvailabilityRequest
    {
        public DateTime From { get; set; }
        public DateTime To { get; set; }
        public int PeopleCount { get; set; }
    }
}
