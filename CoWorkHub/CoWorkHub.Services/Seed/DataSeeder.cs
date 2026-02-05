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
                    new City { CityName = "Sarajevo", CountryId = 1, PostalCode = "71000", Latitude = 43.8476, Longitude = 18.3564 },
                    new City { CityName = "Mostar", CountryId = 1, PostalCode = "88000", Latitude = 43.3433, Longitude = 17.8081 },
                    new City { CityName = "Zagreb", CountryId = 2, PostalCode = "10000", Latitude = 45.8150, Longitude = 15.9819 },
                    new City { CityName = "Split", CountryId = 2, PostalCode = "21000", Latitude = 43.5081, Longitude = 16.4402 },
                    new City { CityName = "Belgrade", CountryId = 3, PostalCode = "11000", Latitude = 44.8170, Longitude = 20.4572 },
                    new City { CityName = "Novi Sad", CountryId = 3, PostalCode = "21000", Latitude = 45.2504, Longitude = 19.8499 },
                    new City { CityName = "Ljubljana", CountryId = 4, PostalCode = "1000", Latitude = 46.0569, Longitude = 14.5058 },
                    new City { CityName = "Podgorica", CountryId = 5, PostalCode = "81000", Latitude = 42.4304, Longitude = 19.2594 },
                    new City { CityName = "Berlin", CountryId = 6, PostalCode = "10115", Latitude = 52.5200, Longitude = 13.4050 },
                    new City { CityName = "Vienna", CountryId = 7, PostalCode = "1010", Latitude = 48.2082, Longitude = 16.3738 }
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
                var imagePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "users", "desktop-profile.png");
                byte[] imageBytes = File.Exists(imagePath) ? File.ReadAllBytes(imagePath) : null;

                var user1Salt = passwordService.GenerateSalt();
                var user1Hash = passwordService.GenerateHash(user1Salt, "test");
                var imagePath2 = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "users", "mobile-profile.jpg");
                byte[] imageBytes2 = File.Exists(imagePath2) ? File.ReadAllBytes(imagePath2) : null;

                var user2Salt = passwordService.GenerateSalt();
                var user2Hash = passwordService.GenerateHash(user2Salt, "test");
                var imagePath3 = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "users", "mobile-profile.jpg");
                byte[] imageBytes3 = File.Exists(imagePath3) ? File.ReadAllBytes(imagePath3) : null;

                var user3Salt = passwordService.GenerateSalt();
                var user3Hash = passwordService.GenerateHash(user3Salt, "test");

                var user4Salt = passwordService.GenerateSalt();
                var user4Hash = passwordService.GenerateHash(user4Salt, "test");

                var user5Salt = passwordService.GenerateSalt();
                var user5Hash = passwordService.GenerateHash(user5Salt, "test");

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
                        ProfileImage = imageBytes,
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
                        PasswordSalt = user1Salt,
                        PasswordHash = user1Hash,
                        ProfileImage = imageBytes2,
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
                        ProfileImage = imageBytes3,
                        CityId = 3,
                        IsActive = true
                    },
                    new User
                    {
                        FirstName = "Haris",
                        LastName = "Beglerović",
                        Email = "haris.beglerovic@gmail.com",
                        Username = "harinjo",
                        PhoneNumber = "061498711",
                        PasswordSalt = user3Salt,
                        PasswordHash = user3Hash,
                        CityId = 4,
                        IsActive = true
                    },
                    new User
                    {
                        FirstName = "Hana",
                        LastName = "Kovačević",
                        Email = "hana.kovacevic@example.com",
                        Username = "hancii",
                        PhoneNumber = "062066409",
                        PasswordSalt = user4Salt,
                        PasswordHash = user4Hash,
                        CityId = 5,
                        IsActive = true
                    },
                    new User
                    {
                        FirstName = "Najla",
                        LastName = "Kevelj",
                        Email = "najla.kevelj@example.com",
                        Username = "najlaaa",
                        PhoneNumber = "063516778",
                        PasswordSalt = user5Salt,
                        PasswordHash = user5Hash,
                        CityId = 7,
                        IsActive = true,
                        
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
                    new UserRole { UserId = 3, RoleId = 2 },
                    new UserRole { UserId = 4, RoleId = 2 },
                    new UserRole { UserId = 5, RoleId = 2 },
                    new UserRole { UserId = 6, RoleId = 1 }
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
                        Description = "Moderni prostor za rad u centru Sarajeva",
                        Address = "Zmaja od Bosne 33, 71000",
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                        IsDeleted = false,
                        Latitude = 43.854192,
                        Longitude = 18.392599
                    },
                    new WorkingSpace
                    {
                        Name = "Sarajevo Hub Center",
                        CityId = 1,
                        Description = "Moderni coworking prostor idealan za digitalne nomade",
                        Address = "Hasana Brkića 12, 71000",
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                        IsDeleted = false,
                        Latitude = 43.850769,
                        Longitude = 18.392367
                    },
                    new WorkingSpace
                    {
                        Name = "Zagreb BizLab",
                        CityId = 3,
                        Description = "Prostor za startup-e i freelancere u Zagrebu",
                        Address = "Savska cesta 41, 10000",
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                        IsDeleted = false,
                        Latitude = 45.796016,
                        Longitude = 15.959896
                    },
                    new WorkingSpace
                     {
                         Name = "HUB365",
                         CityId = 3,
                         Description = "Moderni working prostor u Zagrebu",
                         Address = "Maksimir, 10000",
                         CreatedAt = DateTime.UtcNow,
                         CreatedBy = 1,
                         IsDeleted = false,
                         Latitude = 45.816095,
                         Longitude = 16.001147
                    },
                    new WorkingSpace
                    {
                        Name = "Mostar Spaces",
                        CityId = 2,
                        Description = "Urban i produktivan coworking prostor",
                        Address = "Kneza Domagoja bb, 88000",
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                        IsDeleted = false,
                        Latitude = 43.345714,
                        Longitude= 17.805764
                    },
                    new WorkingSpace
                    {
                        Name = "Connective",
                        CityId = 2,
                        Description = "Renovirana industrijska zgrada s loft prostorima",
                        Address = "Stjepana Radića 72, 88000",
                        CreatedAt = DateTime.UtcNow,
                        CreatedBy = 1,
                        IsDeleted = false,
                        Latitude = 43.346463,
                        Longitude = 17.801427
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
                    new Resource { ResourceName = "Whiteboard" },
                    new Resource { ResourceName = "Printer" },
                    new Resource { ResourceName = "Flipchart" },
                    new Resource { ResourceName = "Air Conditioning" }
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
                    new PaymentMethod { PaymentMethodName = "PayPal" }
                );
                context.SaveChanges();
            }

            // 12. Space Units
            if (!context.SpaceUnits.Any())
            {
                context.SpaceUnits.AddRange(
                    // Tech Hub Sarajevo
                    new SpaceUnit
                    {
                        WorkingSpaceId = 1,
                        Name = "Tech Hub Sarajevo - Private Office 1",
                        Description = "Potpuno opremljena kancelarija za male timove do 4 osobe.",
                        WorkspaceTypeId = 2,
                        Capacity = 4,
                        PricePerDay = 60,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 1,
                        Name = "Tech Hub Sarajevo - Private Office 2",
                        Description = "Mirna kancelarija sa prirodnim svjetlom, idealna za startupe.",
                        WorkspaceTypeId = 2,
                        Capacity = 3,
                        PricePerDay = 50,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 1,
                        Name = "Tech Hub Sarajevo - Meeting Room A",
                        Description = "Moderna sala za sastanke sa projektorom i TV ekranom.",
                        WorkspaceTypeId = 3,
                        Capacity = 10,
                        PricePerDay = 70,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 1,
                        Name = "Tech Hub Sarajevo - Hot Desk Zone",
                        Description = "Zajednički prostor sa 15 radnih mjesta.",
                        WorkspaceTypeId = 1,
                        Capacity = 15,
                        PricePerDay = 12,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },

                    // Sarajevo Hub Center
                    new SpaceUnit
                    {
                        WorkingSpaceId = 2,
                        Name = "Sarajevo Hub Center - Private Office 1",
                        Description = "Potpuno opremljena kancelarija za male timove do 4 osobe.",
                        WorkspaceTypeId = 2,
                        Capacity = 4,
                        PricePerDay = 60,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 2,
                        Name = "Sarajevo Hub Center - Meeting Room Vucko",
                        Description = "Moderna sala za sastanke sa projektorom i TV ekranom.",
                        WorkspaceTypeId = 3,
                        Capacity = 8,
                        PricePerDay = 65,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 2,
                        Name = "Sarajevo Hub Center - Hot Desk Zone",
                        Description = "Otvoren prostor sa 20 zajedničkih radnih mjesta.",
                        WorkspaceTypeId = 1,
                        Capacity = 20,
                        PricePerDay = 12,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },

                    // Mostar Spaces
                    new SpaceUnit
                    {
                        WorkingSpaceId = 5,
                        Name = "Mostar Spaces - Private Office",
                        Description = "Kancelarija za 3-4 osobe, opremljena ergonomski.",
                        WorkspaceTypeId = 2,
                        Capacity = 4,
                        PricePerDay = 55,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 5,
                        Name = "Mostar Spaces - Meeting Room",
                        Description = "Sala za sastanke sa video konferencijskom opremom.",
                        WorkspaceTypeId = 3,
                        Capacity = 10,
                        PricePerDay = 70,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 5,
                        Name = "Mostar Spaces - Open Space",
                        Description = "Zajednički prostor sa 25 radnih mjesta.",
                        WorkspaceTypeId = 1,
                        Capacity = 25,
                        PricePerDay = 15,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },

                    // Connective
                    new SpaceUnit
                    {
                        WorkingSpaceId = 6,
                        Name = "Connective - Loft Office 1",
                        Description = "Moderni loft za male timove.",
                        WorkspaceTypeId = 2,
                        Capacity = 4,
                        PricePerDay = 65,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 6,
                        Name = "Connective - Loft Office 2",
                        Description = "Mirna i svijetla kancelarija idealna za fokusiran rad.",
                        WorkspaceTypeId = 2,
                        Capacity = 3,
                        PricePerDay = 55,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 6,
                        Name = "Connective - Meeting Room Loft",
                        Description = "Loft sala za sastanke sa AV opremom.",
                        WorkspaceTypeId = 3,
                        Capacity = 12,
                        PricePerDay = 75,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 6,
                        Name = "Connective - Hot Desk Zone",
                        Description = "Otvoren prostor sa 20 zajedničkih radnih mjesta.",
                        WorkspaceTypeId = 1,
                        Capacity = 20,
                        PricePerDay = 14,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },

                    // Zagreb BizLab
                    new SpaceUnit
                    {
                        WorkingSpaceId = 3,
                        Name = "Zagreb BizLab - Private Office 1",
                        Description = "Potpuno opremljena kancelarija za male timove do 4 osobe.",
                        WorkspaceTypeId = 2,
                        Capacity = 4,
                        PricePerDay = 60,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 3,
                        Name = "Zagreb BizLab - Meeting Room Alpha",
                        Description = "Moderna sala za sastanke sa projektorom i TV ekranom.",
                        WorkspaceTypeId = 3,
                        Capacity = 10,
                        PricePerDay = 70,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 3,
                        Name = "Zagreb BizLab - Hot Desk Zone",
                        Description = "Zajednički prostor sa 15 radnih mjesta.",
                        WorkspaceTypeId = 1,
                        Capacity = 15,
                        PricePerDay = 12,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },

                    // HUB365
                    new SpaceUnit
                    {
                        WorkingSpaceId = 4,
                        Name = "HUB365 - Private Office",
                        Description = "Udobna kancelarija za male timove, potpuno opremljena.",
                        WorkspaceTypeId = 2,
                        Capacity = 4,
                        PricePerDay = 60,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 4,
                        Name = "HUB365 - Meeting Room",
                        Description = "Moderna sala za sastanke sa video konferencijskom opremom.",
                        WorkspaceTypeId = 3,
                        Capacity = 8,
                        PricePerDay = 65,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    },
                    new SpaceUnit
                    {
                        WorkingSpaceId = 4,
                        Name = "HUB365 - Hot Desk Zone",
                        Description = "Otvoren prostor sa 18 zajedničkih radnih mjesta.",
                        WorkspaceTypeId = 1,
                        Capacity = 18,
                        PricePerDay = 13,
                        StateMachine = "draft",
                        CreatedAt = DateTime.UtcNow
                    }
                );
                context.SaveChanges();
            }


            // 12. Space Units Resources
            if (!context.SpaceUnitResources.Any())
            {
                context.SpaceUnitResources.AddRange(
                    // Tech Hub Sarajevo
                    new SpaceUnitResource { SpaceUnitId = 1, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 }, // Wi-Fi
                    new SpaceUnitResource { SpaceUnitId = 1, ResourcesId = 5, CreatedAt = DateTime.UtcNow, CreatedBy = 1 }, // Printer
                    new SpaceUnitResource { SpaceUnitId = 2, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 2, ResourcesId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = 1 }, // Projector
                    new SpaceUnitResource { SpaceUnitId = 3, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 3, ResourcesId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 3, ResourcesId = 4, CreatedAt = DateTime.UtcNow, CreatedBy = 1 }, // Whiteboard
                    new SpaceUnitResource { SpaceUnitId = 4, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 4, ResourcesId = 3, CreatedAt = DateTime.UtcNow, CreatedBy = 1 }, // Coffee Machine

                    // Sarajevo Hub Center
                    new SpaceUnitResource { SpaceUnitId = 5, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 5, ResourcesId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 6, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 6, ResourcesId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 6, ResourcesId = 6, CreatedAt = DateTime.UtcNow, CreatedBy = 1 }, // Flipchart

                    // Mostar Spaces
                    new SpaceUnitResource { SpaceUnitId = 7, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 7, ResourcesId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 7, ResourcesId = 3, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 8, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 8, ResourcesId = 3, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 8, ResourcesId = 4, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },

                    // Connective
                    new SpaceUnitResource { SpaceUnitId = 9, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 9, ResourcesId = 7, CreatedAt = DateTime.UtcNow, CreatedBy = 1 }, // Air Conditioning
                    new SpaceUnitResource { SpaceUnitId = 10, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 10, ResourcesId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 10, ResourcesId = 6, CreatedAt = DateTime.UtcNow, CreatedBy = 1 }, // Flipchart

                    // Zagreb BizLab
                    new SpaceUnitResource { SpaceUnitId = 11, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 11, ResourcesId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 12, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 12, ResourcesId = 3, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },

                    // HUB365
                    new SpaceUnitResource { SpaceUnitId = 13, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 13, ResourcesId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 13, ResourcesId = 7, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 14, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 14, ResourcesId = 3, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 15, ResourcesId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = 1 },
                    new SpaceUnitResource { SpaceUnitId = 15, ResourcesId = 4, CreatedAt = DateTime.UtcNow, CreatedBy = 1 }
                );
                context.SaveChanges();
            }
        }
    }
}