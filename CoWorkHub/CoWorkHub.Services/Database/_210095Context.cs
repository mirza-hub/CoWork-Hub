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

    public virtual DbSet<SpaceResource> SpaceResources { get; set; }

    public virtual DbSet<User> Users { get; set; }

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
            entity.HasKey(e => e.ReservationId).HasName("PK__Reservat__B7EE5F242E0ED512");

            entity.ToTable("Reservation");

            entity.Property(e => e.CanceledAt).HasColumnType("datetime");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.EndDate).HasColumnType("datetime");
            entity.Property(e => e.StartDate).HasColumnType("datetime");
            entity.Property(e => e.TotalPrice).HasColumnType("decimal(10, 2)");

            entity.HasOne(d => d.ReservationStatus).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.ReservationStatusId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reservation_ReservationStatus");

            entity.HasOne(d => d.Users).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.UsersId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reservation_Users");

            entity.HasOne(d => d.WorkingSpaces).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.WorkingSpacesId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reservation_WorkingSpaces");
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
            entity.HasKey(e => e.ReviewsId).HasName("PK__Reviews__64C7C0ED5D0E3FBD");

            entity.Property(e => e.Comment).HasMaxLength(250);
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DeletedAt).HasColumnType("datetime");
            entity.Property(e => e.ModifiedAt).HasColumnType("datetime");

            entity.HasOne(d => d.DeletedByNavigation).WithMany(p => p.ReviewDeletedByNavigations)
                .HasForeignKey(d => d.DeletedBy)
                .HasConstraintName("FK_ReviewsDeletedBy_Users");

            entity.HasOne(d => d.Users).WithMany(p => p.ReviewUsers)
                .HasForeignKey(d => d.UsersId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reviews_Users");

            entity.HasOne(d => d.WorkingSpaces).WithMany(p => p.Reviews)
                .HasForeignKey(d => d.WorkingSpacesId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reviews_WorkingSpaces");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.RolesId).HasName("PK__Roles__C4B27840A7A06CDF");

            entity.Property(e => e.Description).HasMaxLength(100);
            entity.Property(e => e.RoleName).HasMaxLength(50);
        });

        modelBuilder.Entity<SpaceResource>(entity =>
        {
            entity.HasKey(e => e.SpaceResourcesId).HasName("PK__SpaceRes__56967D54D4E076DF");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DeletedAt).HasColumnType("datetime");
            entity.Property(e => e.ModifiedAt).HasColumnType("datetime");

            entity.HasOne(d => d.CreatedByNavigation).WithMany(p => p.SpaceResourceCreatedByNavigations)
                .HasForeignKey(d => d.CreatedBy)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SpaceResourcesCreatedBy_Users");

            entity.HasOne(d => d.DeletedByNavigation).WithMany(p => p.SpaceResourceDeletedByNavigations)
                .HasForeignKey(d => d.DeletedBy)
                .HasConstraintName("FK_SpaceResourcesDeletedBy_Users");

            entity.HasOne(d => d.ModifiedByNavigation).WithMany(p => p.SpaceResourceModifiedByNavigations)
                .HasForeignKey(d => d.ModifiedBy)
                .HasConstraintName("FK_SpaceResourcesModifiedBy_Users");

            entity.HasOne(d => d.Resources).WithMany(p => p.SpaceResources)
                .HasForeignKey(d => d.ResourcesId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SpaceResources_Resources");

            entity.HasOne(d => d.WorkingSpaces).WithMany(p => p.SpaceResources)
                .HasForeignKey(d => d.WorkingSpacesId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SpaceResources_WorkingSpaces");
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
            entity.Property(e => e.ProfileImageUrl).HasMaxLength(250);
            entity.Property(e => e.Username).HasMaxLength(50);

            entity.HasOne(d => d.City).WithMany(p => p.Users)
                .HasForeignKey(d => d.CityId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Users_City");

            entity.HasOne(d => d.Role).WithMany(p => p.Users)
                .HasForeignKey(d => d.RoleId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Users_Roles");
        });

        modelBuilder.Entity<WorkingSpace>(entity =>
        {
            entity.HasKey(e => e.WorkingSpacesId).HasName("PK__WorkingS__A2EB71C9F9A3BC23");

            entity.Property(e => e.Capacity).HasMaxLength(50);
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.DeletedAt).HasColumnType("datetime");
            entity.Property(e => e.Description).HasMaxLength(200);
            entity.Property(e => e.ModifiedAt).HasColumnType("datetime");
            entity.Property(e => e.Name).HasMaxLength(50);
            entity.Property(e => e.Price).HasMaxLength(50);

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

            entity.HasOne(d => d.WorkingSpaceStatus).WithMany(p => p.WorkingSpaces)
                .HasForeignKey(d => d.WorkingSpaceStatusId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_WorkingSpaces_WorkingSpaceStatus");

            entity.HasOne(d => d.WorkspaceType).WithMany(p => p.WorkingSpaces)
                .HasForeignKey(d => d.WorkspaceTypeId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_WorkingSpaces_WorkspaceType");
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

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
