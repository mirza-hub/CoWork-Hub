using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class WorkingSpace : ISoftDeletable
{
    public int WorkingSpacesId { get; set; }

    public string Name { get; set; } = null!;

    public int CityId { get; set; }

    public string Description { get; set; } = null!;

    public string Address { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public int CreatedBy { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public int? ModifiedBy { get; set; }

    public DateTime? DeletedAt { get; set; }

    public int? DeletedBy { get; set; }

    public virtual City City { get; set; } = null!;

    public virtual User CreatedByNavigation { get; set; } = null!;

    public virtual User? DeletedByNavigation { get; set; }

    public virtual User? ModifiedByNavigation { get; set; }

    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

    public virtual ICollection<SpaceUnit> SpaceUnits { get; set; } = new List<SpaceUnit>();

    public virtual ICollection<WorkingSpaceImage> WorkingSpaceImages { get; set; } = new List<WorkingSpaceImage>();

    public bool IsDeleted { get; set; } = false;
}
