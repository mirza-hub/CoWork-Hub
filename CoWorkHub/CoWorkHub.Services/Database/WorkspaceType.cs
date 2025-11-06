using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class WorkspaceType : ISoftDeletable
{
    public int WorkspaceTypeId { get; set; }

    public string TypeName { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public DateTime? DeletedAt { get; set; }

    public virtual ICollection<WorkingSpace> WorkingSpaces { get; set; } = new List<WorkingSpace>();

    public bool IsDeleted { get; set; } = false;
}
