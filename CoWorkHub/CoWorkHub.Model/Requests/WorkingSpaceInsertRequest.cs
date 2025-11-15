using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class WorkingSpaceInsertRequest
    {
        public string Name { get; set; } = null!;
        public int CityId { get; set; } 
        public string Description { get; set; } = null!;
        public string Address { get; set; } = null!;
    }
}
