using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class WorkingSpaceInsertRequest
    {
        public string Name { get; set; } = null!;
        public string Description { get; set; } = null!;
        public int CityId { get; set; } 
        public int Capacity { get; set; }
        public decimal Price { get; set; }
        public int WorkspaceTypeId { get; set; }
    }
}
