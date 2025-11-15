using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class SpaceUnitResource : ISoftDeletable
{
    public int SpaceResourcesId { get; set; }

    public int SpaceUnitId { get; set; }

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

    public virtual SpaceUnit SpaceUnit { get; set; } = null!;

    public bool IsDeleted { get; set; } = false;
}
