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

    public virtual ICollection<SpaceResource> SpaceResources { get; set; } = new List<SpaceResource>();

    public bool IsDeleted { get; set; } = false;
}
