using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class WorkingSpaceSearchObject : BaseSearchObject 
    {
        public string? NameFTS { get; set; }
        public int? CityId { get; set; }
        public string? AddressFTS { get; set; }
        public bool? IsCityIncluded { get; set; }
    }
}
