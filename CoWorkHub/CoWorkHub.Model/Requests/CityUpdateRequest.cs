using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class CityUpdateRequest
    {
        public string? CityName { get; set; } = null!;
        public int? CountryId { get; set; }
    }
}
