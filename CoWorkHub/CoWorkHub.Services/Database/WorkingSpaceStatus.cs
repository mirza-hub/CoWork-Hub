using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class WorkingSpaceStatus : ISoftDeletable
{
    public int WorkingSpaceStatusId { get; set; }

    public string WorkingSpaceStatusName { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public DateTime? DeletedAt { get; set; }

    public bool IsDeleted { get; set; } = false;
}
