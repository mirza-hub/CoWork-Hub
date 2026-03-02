using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class Notification : ISoftDeletable
{
    public int NotificationId { get; set; }

    public int UserId { get; set; }

    public string Message { get; set; } = null!;

    public bool IsRead { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? DeletedAt { get; set; }

    public virtual User User { get; set; } = null!;

    public bool IsDeleted { get; set; } = false;
}
