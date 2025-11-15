using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class RoleSearchObject : BaseSearchObject
    {
        public string? RoleNameGTE { get; set; }
        public string? DescriptionGTE { get; set; }
    }
}
