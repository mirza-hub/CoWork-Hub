using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Database
{
    public partial class SpaceUnit : ISoftDeletable
    {
        public int SpaceUnitId { get; set; }

        public int WorkingSpaceId { get; set; }
        
        public string Name { get; set; } = null!;
        
        public string Description { get; set; } = null!;

        public int WorkspaceTypeId { get; set; }

        public int Capacity { get; set; }

        public decimal PricePerDay { get; set; }

        public string StateMachine { get; set; } = null!;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public DateTime? ModifiedAt { get; set; }
        
        public DateTime? DeletedAt { get; set; }
        
        public bool IsDeleted { get; set; } = false;

        public virtual WorkingSpace WorkingSpace { get; set; } = null!;

        public virtual WorkspaceType WorkspaceType { get; set; } = null!;

        public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

        public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

        public virtual ICollection<SpaceUnitResource> SpaceUnitResources { get; set; } = new List<SpaceUnitResource>();

        public virtual ICollection<SpaceUnitImage> SpaceUnitImages { get; set; } = new List<SpaceUnitImage>();
    }
}
