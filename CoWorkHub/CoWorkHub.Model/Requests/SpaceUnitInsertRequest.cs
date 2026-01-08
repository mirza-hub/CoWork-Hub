using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class SpaceUnitInsertRequest
    {
        public int WorkingSpaceId { get; set; }
        public string Name { get; set; } = null!;
        public string Description { get; set; } = null!;
        public int WorkspaceTypeId { get; set; }
        public int Capacity { get; set; }
        public decimal PricePerDay { get; set; }
        public List<Resource> ResourcesList { get; set; } = new List<Resource>();
        public List<string>? Base64Images { get; set; } = new List<string>();
    }
}
