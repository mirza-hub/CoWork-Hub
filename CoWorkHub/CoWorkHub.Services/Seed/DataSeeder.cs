using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;

namespace CoWorkHub.Services.Seed
{
    public static class DataSeeder
    {
        public static void Seed(_210095Context context, IPasswordService passwordService)
        {
            // 1. Countries
            if (!context.Countries.Any())
            {
                context.Countries.AddRange(
                   new Country { CountryName = "Bosnia and Herzegovina" },
                   new Country { CountryName = "Croatia" },
                   new Country { CountryName = "Serbia" },
                   new Country { CountryName = "Slovenia" },
                   new Country { CountryName = "Montenegro" },
                   new Country { CountryName = "Germany" },
                   new Country { CountryName = "Austria" }
               );
                context.SaveChanges();
            }

            // 2. Cities
            if (!context.Cities.Any())
            {
                context.Cities.AddRange(
                    new City { CityName = "Sarajevo", CountryId = 1, PostalCode = "71000" },
                    new City { CityName = "Mostar", CountryId = 1, PostalCode = "88000" },
                    new City { CityName = "Zagreb", CountryId = 2, PostalCode = "10000" },
                    new City { CityName = "Split", CountryId = 2, PostalCode = "21000" },
                    new City { CityName = "Belgrade", CountryId = 3, PostalCode = "11000" },
                    new City { CityName = "Novi Sad", CountryId = 3, PostalCode = "21000" },
                    new City { CityName = "Ljubljana", CountryId = 4, PostalCode = "1000" },
                    new City { CityName = "Podgorica", CountryId = 5, PostalCode = "81000" },
                    new City { CityName = "Berlin", CountryId = 6, PostalCode = "10115" },
                    new City { CityName = "Vienna", CountryId = 7, PostalCode = "1010" }
                );
                context.SaveChanges();
            }

            // 3. Roles
            if (!context.Roles.Any())
            {
                context.Roles.AddRange(
                    new Role { RoleName = "Admin", Description = "System administrator" },
                    new Role { RoleName = "User", Description = "Registered user" }
                );
                context.SaveChanges();
            }

            // 4. Workspaces Types
            if (!context.WorkspaceTypes.Any())
            {
                context.WorkspaceTypes.AddRange(
                    new WorkspaceType { TypeName = "Open Space" },
                    new WorkspaceType { TypeName = "Private Office" },
                    new WorkspaceType { TypeName = "Meeting Room" },
                    new WorkspaceType { TypeName = "Event/Training Hall" }
                );
                context.SaveChanges();
            }

            // 5. Working Space Statuses
            if (!context.WorkingSpaceStatuses.Any())
            {
                context.WorkingSpaceStatuses.AddRange(
                    new WorkingSpaceStatus { WorkingSpaceStatusName = "Active" },
                    new WorkingSpaceStatus { WorkingSpaceStatusName = "Unavailable" }
                );
                context.SaveChanges();
            }

            // 6. Users
            if (!context.Users.Any())
            {
                var adminSalt = passwordService.GenerateSalt();
                var adminHash = passwordService.GenerateHash(adminSalt, "test");

                var userSalt = passwordService.GenerateSalt();
                var userHash = passwordService.GenerateHash(userSalt, "test");

                var user2Salt = passwordService.GenerateSalt();
                var user2Hash = passwordService.GenerateHash(user2Salt, "test");

                context.Users.AddRange(
                    new User
                    {
                        FirstName = "Admin",
                        LastName = "Desktop",
                        Email = "admin@example.com",
                        Username = "desktop",
                        PhoneNumber = "061111111",
                        PasswordSalt = adminSalt,
                        PasswordHash = adminHash,
                        CityId = 1,
                        IsActive = true
                    },
                    new User
                    {
                        FirstName = "User",
                        LastName = "Mobile",
                        Email = "user@example.com",
                        Username = "mobile",
                        PhoneNumber = "062222222",
                        PasswordSalt = userSalt,
                        PasswordHash = userHash,
                        CityId = 3,
                        IsActive = true
                    },
                    new User
                    {
                        FirstName = "Mirza",
                        LastName = "Rahic",
                        Email = "mirza@example.com",
                        Username = "mirzinjo",
                        PhoneNumber = "002312315",
                        PasswordSalt = user2Salt,
                        PasswordHash = user2Hash,
                        CityId = 3,
                        IsActive = true
                    }
                );
                context.SaveChanges();
            }

            // 7. User Roles
            if (!context.UserRoles.Any())
            {
                context.UserRoles.AddRange(
                    new UserRole { UserId = 1, RoleId = 1 },
                    new UserRole { UserId = 2, RoleId = 2 },
                    new UserRole { UserId = 3, RoleId = 1 }
                );
                context.SaveChanges();
            }

            // 8. Working spaces
            if (!context.WorkingSpaces.Any())
            {
                context.WorkingSpaces.AddRange(
                    new WorkingSpace
                    {
                        Name = "Tech Hub Sarajevo",
                        CityId = 1,
                        Description = "Modern coworking space in the center of Sarajevo",
                        Address = "Zmaja od Bosne 33, 71000",
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                        IsDeleted = false
                    },
                    new WorkingSpace
                    {
                        Name = "Zagreb BizLab",
                        CityId = 3,
                        Description = "Space for startup and freelancers in Zagreb",
                        Address = "Savska cesta 41, 10000",
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                        IsDeleted = false
                    },
                    new WorkingSpace
                    {
                        Name = "Mostar Hub",
                        CityId = 2,
                        Description = "Space for startup and freelancers in Zagreb",
                        Address = "Kneza Domagoja bb, 88000",
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                        IsDeleted = false
                    }
                );
                context.SaveChanges();
            }

            // 9. Resources
            if (!context.Resources.Any())
            {
                context.Resources.AddRange(
                    new Resource { ResourceName = "Wi-Fi" },
                    new Resource { ResourceName = "Projector" },
                    new Resource { ResourceName = "Coffee Machine" },
                    new Resource { ResourceName = "Whiteboard" }
                );
                context.SaveChanges();
            }

            // 10. Reservation statuses
            if (!context.ReservationStatuses.Any())
            {
                context.ReservationStatuses.AddRange(
                    new ReservationStatus { StatusName = "Pending" },
                    new ReservationStatus { StatusName = "Confirmed" },
                    new ReservationStatus { StatusName = "Paid" },
                    new ReservationStatus { StatusName = "Canceled" }
                );
                context.SaveChanges();
            }

            // 11. Payment methods
            if (!context.PaymentMethods.Any())
            {
                context.PaymentMethods.AddRange(
                    new PaymentMethod { PaymentMethodName = "Credit Card" },
                    new PaymentMethod { PaymentMethodName = "PayPal" },
                    new PaymentMethod { PaymentMethodName = "Cash" }
                );
                context.SaveChanges();
            }

            // 12. Space Units
            if (!context.SpaceUnits.Any())
            {
                context.SpaceUnits.AddRange(
                    new SpaceUnit 
                    {
                        WorkingSpaceId = 2,
                        Name = "BizLab - Private Office 1",
                        Description = "Fully equipped office for small teams of up to 4 people.",
                        WorkspaceTypeId = 2,
                        Capacity = 4,
                        PricePerDay = 60,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 2,
                        Name = "BizLab - Private Office 2",
                        Description = "Quiet office with natural light, ideal for startups.",
                        WorkspaceTypeId = 2,
                        Capacity = 3,
                        PricePerDay = 50,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 2,
                        Name = "BizLab - Meeting Room Alpha",
                        Description = "Modern meeting room with projector and TV screen.",
                        WorkspaceTypeId = 3,
                        Capacity = 10,
                        PricePerDay = 70,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 2,
                        Name = "BizLab - Training Hall",
                        Description = "Large hall suitable for workshops and trainings for up to 30 participants.",
                        WorkspaceTypeId = 4,
                        Capacity = 30,
                        PricePerDay = 120,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 2,
                        Name = "BizLab - Hot Desk Zone A",
                        Description = "Common space with 15 workplaces.",
                        WorkspaceTypeId = 1,
                        Capacity = 15,
                        PricePerDay = 12,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 1,
                        Name = "SarajevoHub - Private Office 1",
                        Description = "Fully equipped office for small teams of up to 4 people.",
                        WorkspaceTypeId = 2,
                        Capacity = 4,
                        PricePerDay = 60,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 1,
                        Name = "SarajevoHub - Private Office 2",
                        Description = "Quiet office with natural light, ideal for startups.",
                        WorkspaceTypeId = 2,
                        Capacity = 3,
                        PricePerDay = 50,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 1,
                        Name = "SarajevoHub - Meeting Room Vucko",
                        Description = "Modern meeting room with projector and TV screen.",
                        WorkspaceTypeId = 3,
                        Capacity = 10,
                        PricePerDay = 70,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 3,
                        Name = "MostarHub - Training Hall",
                        Description = "Large hall suitable for workshops and trainings for up to 30 participants.",
                        WorkspaceTypeId = 4,
                        Capacity = 30,
                        PricePerDay = 120,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 3,
                        Name = "MostarHub - Open Space ",
                        Description = "Common space with 20 workplaces.",
                        WorkspaceTypeId = 1,
                        Capacity = 20,
                        PricePerDay = 12,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    }
                );
                context.SaveChanges();
            }

            // 12.Space Units
            if (!context.SpaceUnitResources.Any())
            {
                context.SpaceUnitResources.AddRange(
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 1,
                        ResourcesId = 1,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 1,
                        ResourcesId = 3,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 2,
                        ResourcesId = 1,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 2,
                        ResourcesId = 3,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 3,
                        ResourcesId = 1,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 3,
                        ResourcesId = 2,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 3,
                        ResourcesId = 3,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 4,
                        ResourcesId = 1,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 4,
                        ResourcesId = 4,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 5,
                        ResourcesId = 1,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 5,
                        ResourcesId = 2,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 6,
                        ResourcesId = 1,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 6,
                        ResourcesId = 2,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 6,
                        ResourcesId = 4,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 7,
                        ResourcesId = 1,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 7,
                        ResourcesId = 2,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 7,
                        ResourcesId = 4,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 8,
                        ResourcesId = 1,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 8,
                        ResourcesId = 3,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 8,
                        ResourcesId = 4,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 9,
                        ResourcesId = 1,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 9,
                        ResourcesId = 3,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 10,
                        ResourcesId = 1,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    },
                    new SpaceUnitResource
                    {
                        SpaceUnitId = 10,
                        ResourcesId = 3,
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                    }
                    );
                context.SaveChanges();
            }
        }
    }
}