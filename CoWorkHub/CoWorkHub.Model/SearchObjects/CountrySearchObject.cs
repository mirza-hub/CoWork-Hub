using CoWorkHub.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class CountrySearchObject : BaseSearchObject
    {
        public string? CountryNameGTE { get; set; }
    }
}
