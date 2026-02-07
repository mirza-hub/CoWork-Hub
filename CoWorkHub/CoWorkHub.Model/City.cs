using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class City
    {
        public int CityId { get; set; }
        public string CityName { get; set; } = null!;
        public string PostalCode { get; set; } = null!;
        public double? Latitude { get; set; }
        public double? Longitude { get; set; }
        public int CountryId { get; set; }
        public virtual Country Country { get; set; } = null!;
        public bool IsDeleted { get; set; } = false;
    }
}
