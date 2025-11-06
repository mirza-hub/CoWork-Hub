using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class WorkingSpaceSearchObject : BaseSearchObject 
    {
        public string? NameFTS { get; set; }
        public int? CityId { get; set; }
        public int? WorkspaceTypeId { get; set; }
        public int? CapacityGTE { get; set; }
        public int? CapacityLTE { get; set; }
        public decimal? PriceGTE { get; set; }
        public decimal? PriceLTE { get; set; }
    }
}
