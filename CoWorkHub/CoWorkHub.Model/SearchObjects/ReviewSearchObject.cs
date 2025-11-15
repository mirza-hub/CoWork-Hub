using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class ReviewSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? SpaceUnitId { get; set; }
        public byte? RatingFrom { get; set; }
        public byte? RatingTo { get; set; }
        public DateTime? CreatedFrom { get; set; }
        public DateTime? CreatedTo { get; set; }
        public bool IncludeUser { get; set; } = false;
        public bool IncludeSpaceUnit { get; set; } = false;
    }
}
