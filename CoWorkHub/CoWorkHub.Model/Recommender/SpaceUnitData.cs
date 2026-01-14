using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Recommender
{
    public class SpaceUnitData
    {
        public int SpaceUnitId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string WorkspaceType { get; set; }
        public int Capacity { get; set; }
        public float PricePerDay { get; set; }
        public string City { get; set; }
        public string Resources { get; set; }
        public float AverageRating { get; set; }
    }
}
