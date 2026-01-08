using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class WorkingSpaceUpdateRequest
    {
        public string? Name { get; set; } = null!;
        public int? CityId { get; set; }
        public string? Description { get; set; } = null!;
        public string? Address { get; set; } = null!;
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
    }
}
