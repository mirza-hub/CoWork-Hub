using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class SpaceUnitInsertRequest
    {
        public int WorkingSpacesId { get; set; }
        public string Name { get; set; } = null!;
        public string Description { get; set; } = null!;
        public int WorkspaceTypeId { get; set; }
        public int Capacity { get; set; }
        public decimal PricePerDay { get; set; }
    }
}
