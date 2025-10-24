﻿using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class City
    {
        public int CityId { get; set; }
        public string CityName { get; set; } = null!;
        public string PostalCode { get; set; } = null!;
        public int CountryId { get; set; }
        public string CountryName { get; set; } = null!;
    }
}
