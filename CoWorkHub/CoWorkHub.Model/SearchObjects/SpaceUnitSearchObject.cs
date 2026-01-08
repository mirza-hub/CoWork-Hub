using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class SpaceUnitSearchObject : BaseSearchObject
    {
        public int? SpaceUnitId { get; set; }
        public int? WorkingSpaceId { get; set; }
        public string? Name { get; set; }
        public int? WorkspaceTypeId { get; set; }
        public int? CityId { get; set; }
        public int? CapacityFrom { get; set; }
        public int? CapacityTo { get; set; }
        public decimal? PriceFrom { get; set; }
        public decimal? PriceTo { get; set; }
        public DateTime? From { get; set; }
        public DateTime? To { get; set; }
        public int? PeopleCount { get; set; }
        public string? StateMachine { get; set; }
        public bool ByMonth { get; set; } = false;
        public bool IncludeAll { get; set; } = false;
        public bool IncludeWorkingSpace { get; set; } = false;
        public bool IncludeWorkspaceType { get; set; } = false;
        public bool IncludeResources { get; set; } = false;
        public bool IncludeImages { get; set; } = false;
    }
}
