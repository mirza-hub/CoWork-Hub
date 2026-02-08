using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class User : ISoftDeletable
{
    public int UsersId { get; set; }

    public string FirstName { get; set; } = null!;

    public string LastName { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string Username { get; set; } = null!;

    public string PhoneNumber { get; set; } = null!;

    public byte[]? ProfileImage { get; set; }

    public string PasswordSalt { get; set; } = null!;

    public string PasswordHash { get; set; } = null!;

    public int CityId { get; set; }

    public bool IsActive { get; set; } = true;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public DateTime? ModifiedAt { get; set; }

    public DateTime? DeletedAt { get; set; }

    public virtual ICollection<ActivityLog> ActivityLogs { get; set; } = new List<ActivityLog>();

    public virtual City City { get; set; } = null!;

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();

    public virtual ICollection<Review> ReviewDeletedByNavigations { get; set; } = new List<Review>();

    public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();

    public virtual ICollection<SpaceUnitResource> SpaceUnitResourceCreatedByNavigations { get; set; } = new List<SpaceUnitResource>();

    public virtual ICollection<SpaceUnitResource> SpaceUnitResourceDeletedByNavigations { get; set; } = new List<SpaceUnitResource>();

    public virtual ICollection<SpaceUnitResource> SpaceUnitResourceModifiedByNavigations { get; set; } = new List<SpaceUnitResource>();

    public virtual ICollection<WorkingSpace> WorkingSpaceCreatedByNavigations { get; set; } = new List<WorkingSpace>();

    public virtual ICollection<WorkingSpace> WorkingSpaceDeletedByNavigations { get; set; } = new List<WorkingSpace>();

    public virtual ICollection<WorkingSpaceImage> WorkingSpaceImages { get; set; } = new List<WorkingSpaceImage>();

    public virtual ICollection<WorkingSpace> WorkingSpaceModifiedByNavigations { get; set; } = new List<WorkingSpace>();

    public bool IsDeleted { get; set; } = false;
}
