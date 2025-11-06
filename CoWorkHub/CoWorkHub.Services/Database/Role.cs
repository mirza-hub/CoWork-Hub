using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class Role : ISoftDeletable
{
    public int RolesId { get; set; }

    public string RoleName { get; set; } = null!;

    public string? Description { get; set; }

    public virtual ICollection<User> Users { get; set; } = new List<User>();

    public DateTime? DeletedAt { get; set; }

    public bool IsDeleted { get; set; } = false;
}
