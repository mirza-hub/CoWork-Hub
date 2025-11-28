using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class ReservationSearchObject : BaseSearchObject
    {
        public string? UserFullName { get; set; }
        public string? SpaceUnitName { get; set; }
        public DateTime? DateFrom { get; set; }
        public DateTime? DateTo { get; set; }
        public decimal? PriceFrom { get; set; }
        public decimal? PriceTo { get; set; }
        public string? StateMachineGTE { get; set; }
        public bool IncludeSpaceUnit { get; set; } = false;
        public bool IncludeUser { get; set; } = false;
    }
}
