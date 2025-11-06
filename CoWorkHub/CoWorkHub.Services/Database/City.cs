using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class City : ISoftDeletable
{
    public int CityId { get; set; }

    public string CityName { get; set; } = null!;

    public int CountryId { get; set; }

    public string PostalCode { get; set; } = null!;

    public virtual Country Country { get; set; } = null!;

    public virtual ICollection<User> Users { get; set; } = new List<User>();

    public virtual ICollection<WorkingSpace> WorkingSpaces { get; set; } = new List<WorkingSpace>();

    public bool IsDeleted { get; set; } = false;

    public DateTime? DeletedAt { get; set; }
}
