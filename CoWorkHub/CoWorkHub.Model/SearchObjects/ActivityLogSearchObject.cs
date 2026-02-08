using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class ActivityLogSearchObject : BaseSearchObject
    {
        public string? Action { get; set; } = null;
        public string? Entity { get; set; } = null;
        public int? UserId { get; set; }
        public DateTime? From { get; set; }
        public DateTime? To { get; set; }
        public string? UserFirstName { get; set; }
        public string? UserLastName { get; set; }
    }
}
