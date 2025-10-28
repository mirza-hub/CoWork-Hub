using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class WorkingSpaceInsertRequest
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public int CityId { get; set; }
        public string Capacity { get; set; }
        public string Price { get; set; }
        public int WorkspaceTypeId { get; set; }
        public int WorkingSpaceStatusId { get; set; }
    }
}
