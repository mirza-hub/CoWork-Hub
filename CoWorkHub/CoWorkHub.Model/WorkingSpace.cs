using System.Collections.Generic;

namespace CoWorkHub.Model
{
    public class WorkingSpace
    {
        public int WorkingSpacesId { get; set; }
        public string Name { get; set; } = null!;
        public int CityId { get; set; }
        public string Description { get; set; } = null!;
        public string Address { get; set; } = null!;
        public bool? IsDeleted { get; set; } = false;
        public virtual City City { get; set; } = null!;
    }
}
