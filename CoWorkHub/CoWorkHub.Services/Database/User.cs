using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class User
{
    public int UsersId { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string Username { get; set; } = null!;

    public string PhoneNumber { get; set; } = null!;

    public string? ProfileImageUrl { get; set; }

    public string PasswordHash { get; set; } = null!;

    public int CityId { get; set; }

    public int RoleId { get; set; }

    public bool IsActive { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public DateTime? DeletedAt { get; set; }

    public virtual ICollection<ActivityLog> ActivityLogs { get; set; } = new List<ActivityLog>();

    public virtual City City { get; set; } = null!;

    public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

    public virtual ICollection<Review> ReviewDeletedByNavigations { get; set; } = new List<Review>();

    public virtual ICollection<Review> ReviewUsers { get; set; } = new List<Review>();

    public virtual Role Role { get; set; } = null!;

    public virtual ICollection<SpaceResource> SpaceResourceCreatedByNavigations { get; set; } = new List<SpaceResource>();

    public virtual ICollection<SpaceResource> SpaceResourceDeletedByNavigations { get; set; } = new List<SpaceResource>();

    public virtual ICollection<SpaceResource> SpaceResourceModifiedByNavigations { get; set; } = new List<SpaceResource>();

    public virtual ICollection<WorkingSpace> WorkingSpaceCreatedByNavigations { get; set; } = new List<WorkingSpace>();

    public virtual ICollection<WorkingSpace> WorkingSpaceDeletedByNavigations { get; set; } = new List<WorkingSpace>();

    public virtual ICollection<WorkingSpaceImage> WorkingSpaceImages { get; set; } = new List<WorkingSpaceImage>();

    public virtual ICollection<WorkingSpace> WorkingSpaceModifiedByNavigations { get; set; } = new List<WorkingSpace>();
}
