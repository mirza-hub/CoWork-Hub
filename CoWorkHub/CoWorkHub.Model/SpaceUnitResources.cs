using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class SpaceUnitResources
    {
        public int SpaceResourcesId { get; set; }
        public int SpaceUnitId { get; set; }
        public int ResourcesId { get; set; }
        public virtual Resource Resources { get; set; } = null!;
        public virtual SpaceUnit SpaceUnit { get; set; } = null!;
    }
}
