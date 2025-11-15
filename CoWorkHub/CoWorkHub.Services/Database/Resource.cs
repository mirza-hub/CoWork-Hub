using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class Resource : ISoftDeletable
{
    public int ResourcesId { get; set; }

    public string ResourceName { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public DateTime? DeletedAt { get; set; }

    public virtual ICollection<SpaceUnitResource> SpaceUnitResources { get; set; } = new List<SpaceUnitResource>();

    public bool IsDeleted { get; set; } = false;
}
