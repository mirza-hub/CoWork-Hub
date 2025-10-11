using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class Role
{
    public int RolesId { get; set; }

    public string RoleName { get; set; } = null!;

    public string? Description { get; set; }

    public virtual ICollection<User> Users { get; set; } = new List<User>();
}
