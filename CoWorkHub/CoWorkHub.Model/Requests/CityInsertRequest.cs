using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class CityInsertRequest
    {
        public string CityName { get; set; } = null!;
        public int CountryId { get; set; }
        public string PostalCode { get; set; } = null!;
    }
}
