using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class CitySearchObject : BaseSearchObject
    {
        public string? CityNameGTE { get; set; }
        public bool IsCountryIncluded { get; set; }
    }
}
