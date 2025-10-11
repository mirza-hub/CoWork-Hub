using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class SpaceResource
{
    public int SpaceResourcesId { get; set; }

    public int WorkingSpacesId { get; set; }

    public int ResourcesId { get; set; }

    public DateTime CreatedAt { get; set; }

    public int CreatedBy { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public int? ModifiedBy { get; set; }

    public DateTime? DeletedAt { get; set; }

    public int? DeletedBy { get; set; }

    public virtual User CreatedByNavigation { get; set; } = null!;

    public virtual User? DeletedByNavigation { get; set; }

    public virtual User? ModifiedByNavigation { get; set; }

    public virtual Resource Resources { get; set; } = null!;

    public virtual WorkingSpace WorkingSpaces { get; set; } = null!;
}
