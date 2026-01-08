using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class SpaceUnitUpdateRequest
    {
        public string? Name { get; set; }
        public string? Description { get; set; }
        public int? Capacity { get; set; }
        public decimal? PricePerDay { get; set; }
        public int? WorkspaceTypeId { get; set; }
        public List<Resource> ResourcesList { get; set; } = new List<Resource>();
    }
}
