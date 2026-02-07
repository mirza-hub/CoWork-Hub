using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class Country
    {
        public int CountryId { get; set; }
        public string CountryName { get; set; }
        public bool IsDeleted { get; set; } = false;
    }
}
