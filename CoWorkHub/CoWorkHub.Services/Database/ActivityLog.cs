using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class ActivityLog
{
    public int ActivityLogId { get; set; }

    public int? UserId { get; set; }

    public string Action { get; set; } = null!;

    public string Entity { get; set; } = null!;

    public string? Description { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public virtual User? User { get; set; } = null!;
}
