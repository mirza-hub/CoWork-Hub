using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class WorkingSpaceImage
{
    public int ImageId { get; set; }

    public int WorkingSpacesId { get; set; }

    public string ImagePath { get; set; } = null!;

    public string? Description { get; set; }

    public DateTime CreatedAt { get; set; }

    public int CreatedBy { get; set; }

    public virtual User CreatedByNavigation { get; set; } = null!;

    public virtual WorkingSpace WorkingSpaces { get; set; } = null!;
}
