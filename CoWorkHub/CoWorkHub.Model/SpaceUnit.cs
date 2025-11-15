using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class SpaceUnit
    {
        public int SpaceUnitId { get; set; }
        public int WorkingSpaceId { get; set; }
        public string Name { get; set; } = null!;
        public string Description { get; set; } = null!;
        public int WorkspaceTypeId { get; set; }
        public int Capacity { get; set; }
        public decimal PricePerDay { get; set; }
        public string StateMachine { get; set; } = null!;
        public bool IsDeleted { get; set; } = false;
        public virtual WorkingSpace WorkingSpace { get; set; } = null!;
        public virtual ICollection<SpaceUnitResources> SpaceUnitResource { get; set; } = new List<SpaceUnitResources>();
        public virtual WorkspaceType WorkspaceType { get; set; } = null!;
    }
}
