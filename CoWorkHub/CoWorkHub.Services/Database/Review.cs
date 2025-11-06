using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class Review : ISoftDeletable
{
    public int ReviewsId { get; set; }

    public int UsersId { get; set; }

    public int WorkingSpacesId { get; set; }

    public byte Rating { get; set; }

    public string Comment { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public DateTime? DeletedAt { get; set; }

    public int? DeletedBy { get; set; }

    public virtual User? DeletedByNavigation { get; set; }

    public virtual User Users { get; set; } = null!;

    public virtual WorkingSpace WorkingSpaces { get; set; } = null!;

    public bool IsDeleted { get; set; } = false;
}
