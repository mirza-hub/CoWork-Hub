using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class WorkingSpace
    {
        public int WorkingSpacesId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; } = null!;
        public int CityId { get; set; }
        public string Capacity { get; set; } = null!;
        public string Price { get; set; } = null!;
        public int WorkspaceTypeId { get; set; }
        public string StateMachine { get; set; } = null!;
    }
}
