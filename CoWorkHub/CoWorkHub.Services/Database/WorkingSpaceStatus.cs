using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class WorkingSpaceStatus
{
    public int WorkingSpaceStatusId { get; set; }

    public string WorkingSpaceStatusName { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public DateTime? DeletedAt { get; set; }

    public virtual ICollection<WorkingSpace> WorkingSpaces { get; set; } = new List<WorkingSpace>();
}
