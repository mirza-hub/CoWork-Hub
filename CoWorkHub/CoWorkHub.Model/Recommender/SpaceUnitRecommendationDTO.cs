using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Recommender
{
    public class SpaceUnitRecommendationDTO
    {
        public int SpaceUnitId { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public decimal PricePerDay { get; set; }
        public string WorkspaceType { get; set; }
        public string City { get; set; }
        public int Capacity { get; set; }
        public List<string> Resources { get; set; }
        public double? AverageRating { get; set; }
        public float RecommendationScore { get; set; }
        public string ImageUrl { get; set; }
    }
}
