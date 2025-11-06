using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class WorkingSpace
    {
        public int WorkingSpacesId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public int CityId { get; set; }
        public string Capacity { get; set; }
        public string Price { get; set; }
        public int WorkspaceTypeId { get; set; }
        public string? StateMachine { get; set; }
    }
}
