using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class SpaceUnitResourcesSearchObject : BaseSearchObject
    {
        public int? SpaceUnitId { get; set; }
        public int? ResourceId { get; set; }
        //public bool IncludeSpaceUnit { get; set; } = false;
        //public bool IncludeResource { get; set; } = false;
    }
}
