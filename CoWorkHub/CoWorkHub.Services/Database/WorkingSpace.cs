using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class WorkingSpace
{
    public int WorkingSpacesId { get; set; }

    public string Name { get; set; } = null!;

    public string Description { get; set; } = null!;

    public int CityId { get; set; }

    public string Capacity { get; set; } = null!;

    public string Price { get; set; } = null!;

    public int WorkspaceTypeId { get; set; }

    public int WorkingSpaceStatusId { get; set; }

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

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

    public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

    public virtual ICollection<SpaceResource> SpaceResources { get; set; } = new List<SpaceResource>();

    public virtual ICollection<WorkingSpaceImage> WorkingSpaceImages { get; set; } = new List<WorkingSpaceImage>();

    public virtual WorkingSpaceStatus WorkingSpaceStatus { get; set; } = null!;

    public virtual WorkspaceType WorkspaceType { get; set; } = null!;
}
