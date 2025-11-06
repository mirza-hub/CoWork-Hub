using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class Country : ISoftDeletable
{
    public int CountryId { get; set; }

    public string CountryName { get; set; } = null!;

    public virtual ICollection<City> Cities { get; set; } = new List<City>();

    public bool IsDeleted { get; set; } = false;

    public DateTime? DeletedAt { get; set; }
}
