using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class UserSearchObject : BaseSearchObject
    {
        public string? FirstNameGTE { get; set; }
        public string? LastNameGTE { get; set; }
        public string? UsernameGTE { get; set; }
        public string? Email { get; set; }
        public int? CityId { get; set; }
        public int? RoleId { get; set; }
        public bool? IsActive { get; set; }
        public bool? IsDeleted { get; set; }
    }
}
