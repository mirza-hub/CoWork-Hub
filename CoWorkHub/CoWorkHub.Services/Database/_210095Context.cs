using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace CoWorkHub.Services.Database;

public partial class _210095Context : DbContext
{
    public _210095Context()
    {
    }

    public _210095Context(DbContextOptions<_210095Context> options)
        : base(options)
    {
    }

    public virtual DbSet<ActivityLog> ActivityLogs { get; set; }

    public virtual DbSet<City> Cities { get; set; }

    public virtual DbSet<Country> Countries { get; set; }

    public virtual DbSet<Notification> Notifications { get; set; }

    public virtual DbSet<Payment> Payments { get; set; }

    public virtual DbSet<PaymentMethod> PaymentMethods { get; set; }

    public virtual DbSet<Reservation> Reservations { get; set; }

    public virtual DbSet<ReservationStatus> ReservationStatuses { get; set; }         

    public virtual DbSet<Resource> Resources { get; set; }

    public virtual DbSet<Review> Reviews { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<SpaceUnit> SpaceUnits { get; set; }

    public virtual DbSet<SpaceUnitImage> SpaceUnitImages { get; set; }

    public virtual DbSet<SpaceUnitResource> SpaceUnitResources { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserRole> UserRoles { get; set; }

    public virtual DbSet<WorkingSpace> WorkingSpaces { get; set; }

    public virtual DbSet<WorkingSpaceImage> WorkingSpaceImages { get; set; }

    public virtual DbSet<WorkingSpaceStatus> WorkingSpaceStatuses { get; set; }

    public virtual DbSet<WorkspaceType> WorkspaceTypes { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Data Source=localhost;Initial Catalog=210095;Trusted_Connection=True;TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<ActivityLog>(entity =>
        {
            entity.HasKey(e => e.ActivityLogId).HasName("PK__Activity__19A9B7AFC7A107AA");

            entity.ToTable("ActivityLog");

            entity.Property(e => e.Action).HasMaxLength(100);
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Description).HasMaxLength(250);

            entity.HasOne(d => d.User).WithMany(p => p.ActivityLogs)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ActivityLog_Users");
        });

        modelBuilder.Entity<City>(entity =>
        {
            entity.HasKey(e => e.CityId).HasName("PK__City__F2D21B7654331DD4");

            entity.ToTable("City");

            entity.Property(e => e.CityName).HasMaxLength(50);
            entity.Property(e => e.PostalCode).HasMaxLength(10);

            entity.HasOne(d => d.Country).WithMany(p => p.Cities)
                .HasForeignKey(d => d.CountryId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_City_Country");
        });

        modelBuilder.Entity<Country>(entity =>
        {
            entity.HasKey(e => e.CountryId).HasName("PK__Country__10D1609F585C5019");

            entity.ToTable("Country");

            entity.Property(e => e.CountryName).HasMaxLength(50);
        });

        modelBuilder.Entity<Notification>(entity =>
        {
            entity.HasKey(e => e.NotificationId).HasName("PK__Notifica__20CF2E12724CECFA");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DeletedAt).HasColumnType("datetime");
            entity.Property(e => e.Message).HasMaxLength(250);

            entity.HasOne(d => d.User).WithMany(p => p.Notifications)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Notifications_Users");
        });

        modelBuilder.Entity<Payment>(entity =>
        {
            entity.HasKey(e => e.PaymentId).HasName("PK__Payment__9B556A38168D4919");

            entity.ToTable("Payment");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DeletedAt).HasColumnType("datetime");
            entity.Property(e => e.Discount).HasColumnType("decimal(5, 2)");
            entity.Property(e => e.ModifiedAt).HasColumnType("datetime");
            entity.Property(e => e.PaymentDate)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.TotalPaymentAmount).HasColumnType("decimal(10, 2)");

            entity.HasOne(d => d.PaymentMethod).WithMany(p => p.Payments)
                .HasForeignKey(d => d.PaymentMethodId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Payment_PaymentMethod");

            entity.HasOne(d => d.Reservation).WithMany(p => p.Payments)
                .HasForeignKey(d => d.ReservationId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Payment_Reservation");
        });

        modelBuilder.Entity<PaymentMethod>(entity =>
        {
            entity.HasKey(e => e.PaymentMethodId).HasName("PK__PaymentM__DC31C1D3A568E9C3");

            entity.ToTable("PaymentMethod");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DeletedAt).HasColumnType("datetime");
            entity.Property(e => e.ModifiedAt).HasColumnType("datetime");
            entity.Property(e => e.PaymentMethodName).HasMaxLength(50);
        });

        modelBuilder.Entity<Reservation>(entity =>
        {
            entity.HasKey(e => e.ReservationId);

            entity.Property(e => e.TotalPrice)
                .HasColumnType("decimal(10, 2)");

            entity.Property(e => e.StartDate)
                .HasColumnType("datetime")
                .IsRequired();

            entity.Property(e => e.EndDate)
                .HasColumnType("datetime")
                .IsRequired();

            entity.Property(e => e.PeopleCount)
                .HasDefaultValue(1);

            entity.Property(e => e.StateMachine)
                .IsRequired();

            entity.Property(e => e.CreatedAt)
                .IsRequired();

            entity.Property(e => e.CanceledAt);

            entity.Property(e => e.DeletedAt);

            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false);

            entity.HasOne(d => d.Users)
                .WithMany(p => p.Reservations)
                .HasForeignKey(d => d.UsersId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reservation_Users");

            entity.HasOne(d => d.SpaceUnit)
                .WithMany(p => p.Reservations)
                .HasForeignKey(d => d.SpaceUnitId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reservation_SpaceUnit");

            entity.HasMany(d => d.Payments)
                .WithOne(p => p.Reservation)
                .HasForeignKey(p => p.ReservationId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_Reservation_Payments");
        });


        modelBuilder.Entity<ReservationStatus>(entity =>
        {
            entity.HasKey(e => e.ReservationStatusId).HasName("PK__Reservat__DFC0EEAA3753D8C2");

            entity.ToTable("ReservationStatus");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DeletedAt).HasColumnType("datetime");
            entity.Property(e => e.ModifiedAt).HasColumnType("datetime");
            entity.Property(e => e.StatusName).HasMaxLength(50);
        });

        modelBuilder.Entity<Resource>(entity =>
        {
            entity.HasKey(e => e.ResourcesId).HasName("PK__Resource__EE325BD4A75B7880");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DeletedAt).HasColumnType("datetime");
            entity.Property(e => e.ModifiedAt).HasColumnType("datetime");
            entity.Property(e => e.ResourceName).HasMaxLength(50);
        });

        modelBuilder.Entity<Review>(entity =>
        {
            entity.HasKey(e => e.ReviewsId);

            entity.Property(e => e.Rating)
                .IsRequired();

            entity.Property(e => e.Comment)
                .IsRequired()
                .HasMaxLength(2000);

            entity.Property(e => e.CreatedAt)
                .IsRequired();

            entity.Property(e => e.ModifiedAt);

            entity.Property(e => e.DeletedAt);

            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false);

            entity.HasOne(d => d.Users)
                .WithMany(p => p.ReviewUsers)
                .HasForeignKey(d => d.UsersId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Review_User");

            entity.HasOne(d => d.SpaceUnit)
                .WithMany(p => p.Reviews)
                .HasForeignKey(d => d.SpaceUnitId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Review_SpaceUnit");

            entity.HasOne(d => d.DeletedByNavigation)
                .WithMany(u => u.ReviewDeletedByNavigations)
                .HasForeignKey(d => d.DeletedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Review_DeletedBy");
        });


        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.RolesId).HasName("PK__Roles__C4B27840A7A06CDF");

            entity.Property(e => e.Description).HasMaxLength(100);
            entity.Property(e => e.RoleName).HasMaxLength(50);
        });

        modelBuilder.Entity<SpaceUnit>(entity =>
        {
            entity.HasKey(e => e.SpaceUnitId);

            entity.Property(e => e.Name)
                .IsRequired()
                .HasMaxLength(200);

            entity.Property(e => e.Description)
                .IsRequired()
                .HasMaxLength(1000);

            entity.Property(e => e.Capacity)
                .IsRequired();

            entity.Property(e => e.PricePerDay)
                .HasColumnType("decimal(10, 2)")
                .IsRequired();

            entity.Property(e => e.StateMachine)
                .IsRequired()
                .HasMaxLength(50);

            entity.Property(e => e.CreatedAt)
                .IsRequired();

            entity.Property(e => e.ModifiedAt);

            entity.Property(e => e.DeletedAt);

            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false);

            entity.HasOne(d => d.WorkingSpace)
                .WithMany(p => p.SpaceUnits)
                .HasForeignKey(d => d.WorkingSpaceId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SpaceUnit_WorkingSpace");

            entity.HasOne(d => d.WorkspaceType)
                .WithMany(p => p.SpaceUnits)
                .HasForeignKey(d => d.WorkspaceTypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SpaceUnit_WorkspaceType");

            entity.HasMany(d => d.Reservations)
                .WithOne(p => p.SpaceUnit)
                .HasForeignKey(p => p.SpaceUnitId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_SpaceUnit_Reservations");

            entity.HasMany(d => d.Reviews)
                .WithOne(p => p.SpaceUnit)
                .HasForeignKey(p => p.SpaceUnitId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_SpaceUnit_Reviews");

            entity.HasMany(d => d.SpaceUnitResources)
                .WithOne(p => p.SpaceUnit)
                .HasForeignKey(p => p.SpaceUnitId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_SpaceUnit_SpaceUnitResources");

            entity.HasMany(d => d.SpaceUnitImages)
                .WithOne(p => p.SpaceUnit)
                .HasForeignKey(p => p.SpaceUnitId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_SpaceUnit_SpaceUnitImages");
        });

        modelBuilder.Entity<SpaceUnitImage>(entity =>
        {
            entity.HasKey(e => e.ImageId);

            entity.Property(e => e.ImagePath)
                .IsRequired()
                .HasMaxLength(500);

            entity.Property(e => e.Description)
                .HasMaxLength(1000);

            entity.Property(e => e.CreatedAt)
                .IsRequired();

            entity.Property(e => e.DeletedAt);

            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false);

            entity.HasOne(d => d.SpaceUnit)
                .WithMany(p => p.SpaceUnitImages)
                .HasForeignKey(d => d.SpaceUnitId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_SpaceUnitImage_SpaceUnit");
        });

        modelBuilder.Entity<SpaceUnitResource>(entity =>
        {
            entity.HasKey(e => e.SpaceResourcesId);

            entity.Property(e => e.CreatedAt)
                .IsRequired();

            entity.Property(e => e.ModifiedAt);

            entity.Property(e => e.DeletedAt);

            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false);

            entity.HasOne(d => d.SpaceUnit)
                .WithMany(p => p.SpaceUnitResources)
                .HasForeignKey(d => d.SpaceUnitId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_SpaceUnitResource_SpaceUnit");

            entity.HasOne(d => d.Resources)
                .WithMany(p => p.SpaceUnitResources)
                .HasForeignKey(d => d.ResourcesId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_SpaceUnitResource_Resource");

            entity.HasOne(d => d.CreatedByNavigation)
                .WithMany(u=>u.SpaceUnitResourceCreatedByNavigations)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SpaceUnitResource_CreatedBy");

            entity.HasOne(d => d.ModifiedByNavigation)
                .WithMany(u => u.SpaceUnitResourceModifiedByNavigations)
                .HasForeignKey(d => d.ModifiedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SpaceUnitResource_ModifiedBy");

            entity.HasOne(d => d.DeletedByNavigation)
                .WithMany(u => u.SpaceUnitResourceDeletedByNavigations)
                .HasForeignKey(d => d.DeletedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SpaceUnitResource_DeletedBy");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UsersId).HasName("PK__Users__A349B062A2433C41");

            entity.HasIndex(e => e.Username, "UQ__Users__536C85E44DEE34AB").IsUnique();

            entity.HasIndex(e => e.Email, "UQ__Users__A9D10534AEE1B60D").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DeletedAt).HasColumnType("datetime");
            entity.Property(e => e.Email).HasMaxLength(50);
            entity.Property(e => e.FirstName).HasMaxLength(50);
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.LastName).HasMaxLength(50);
            entity.Property(e => e.ModifiedAt).HasColumnType("datetime");
            entity.Property(e => e.PasswordHash).HasMaxLength(200);
            entity.Property(e => e.PhoneNumber).HasMaxLength(50);
            entity.Property(e => e.ProfileImageBase64).HasColumnType("nvarchar(max)");
            entity.Property(e => e.Username).HasMaxLength(50);

            entity.HasOne(d => d.City).WithMany(p => p.Users)
                .HasForeignKey(d => d.CityId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Users_City");
        });

        modelBuilder.Entity<WorkingSpace>(entity =>
        {
            entity.HasKey(e => e.WorkingSpacesId).HasName("PK__WorkingS__A2EB71C9F9A3BC23");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DeletedAt).HasColumnType("datetime");
            entity.Property(e => e.Description).HasMaxLength(200);
            entity.Property(e => e.ModifiedAt).HasColumnType("datetime");
            entity.Property(e => e.Name).HasMaxLength(50);

            entity.HasOne(d => d.City).WithMany(p => p.WorkingSpaces)
                .HasForeignKey(d => d.CityId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_WorkingSpaces_City");

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.WorkingSpaceCreatedByNavigations)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_WorkingSpacesCreatedBy_Users");

            entity.HasOne(d => d.DeletedByNavigation).WithMany(p => p.WorkingSpaceDeletedByNavigations)
                .HasForeignKey(d => d.DeletedBy)
                .HasConstraintName("FK_WorkingSpacesDeletedBy_Users");

            entity.HasOne(d => d.ModifiedByNavigation).WithMany(p => p.WorkingSpaceModifiedByNavigations)
                .HasForeignKey(d => d.ModifiedBy)
                .HasConstraintName("FK_WorkingSpacesModifiedBy_Users");

        });

        modelBuilder.Entity<WorkingSpaceImage>(entity =>
        {
            entity.HasKey(e => e.ImageId).HasName("PK__WorkingS__7516F70C380ADEDB");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Description).HasMaxLength(250);
            entity.Property(e => e.ImagePath).HasMaxLength(255);

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.WorkingSpaceImages)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_WorkingSpaceImagesCreatedBy_Users");

            entity.HasOne(d => d.WorkingSpaces).WithMany(p => p.WorkingSpaceImages)
                .HasForeignKey(d => d.WorkingSpacesId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_WorkingSpaceImages_WorkingSpaces");
        });

        modelBuilder.Entity<WorkingSpaceStatus>(entity =>
        {
            entity.HasKey(e => e.WorkingSpaceStatusId).HasName("PK__WorkingS__187BFA3269F9A5A1");

            entity.ToTable("WorkingSpaceStatus");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DeletedAt).HasColumnType("datetime");
            entity.Property(e => e.ModifiedAt).HasColumnType("datetime");
            entity.Property(e => e.WorkingSpaceStatusName).HasMaxLength(50);
        });

        modelBuilder.Entity<WorkspaceType>(entity =>
        {
            entity.HasKey(e => e.WorkspaceTypeId).HasName("PK__Workspac__39CF5B8191065C67");

            entity.ToTable("WorkspaceType");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DeletedAt).HasColumnType("datetime");
            entity.Property(e => e.ModifiedAt).HasColumnType("datetime");
            entity.Property(e => e.TypeName).HasMaxLength(50);
        });

        modelBuilder.Entity<UserRole>(entity =>
        {
            entity.HasKey(ur => ur.UserRoleId);
            entity.ToTable("UserRoles");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.Property(e => e.ModifiedAt)
                .HasColumnType("datetime");

            entity.Property(e => e.DeletedAt)
                .HasColumnType("datetime");

            entity.Property(e => e.IsDeleted)
                .HasDefaultValue(false);

            entity.HasOne(ur => ur.User)
                .WithMany(u => u.UserRoles)
                .HasForeignKey(ur => ur.UserId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_UserRoles_Users");

            entity.HasOne(ur => ur.Role)
                .WithMany(r => r.UserRoles)
                .HasForeignKey(ur => ur.RoleId)
                .OnDelete(DeleteBehavior.Cascade)
                .HasConstraintName("FK_UserRoles_Roles");
        });


        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
