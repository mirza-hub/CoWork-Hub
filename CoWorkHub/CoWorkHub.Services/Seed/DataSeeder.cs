using CoWorkHub.Services.Database;
using CoWorkHub.Services.Helper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Seed
{
    public static class DataSeeder
    {
        public static void Seed(_210095Context context)
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
                    new WorkspaceType { TypeName = "Meeting Room" }
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
                context.Users.AddRange(
                    new User
                    {
                        FirstName = "Admin",
                        LastName = "Desktop",
                        Email = "admin@example.com",
                        Username = "desktop",
                        PhoneNumber = "061111111",
                        PasswordHash = PasswordHelper.SetPassword("test"),
                        CityId = 1,
                        RoleId = 1,
                        IsActive = true
                    },
                    new User
                    {
                        FirstName = "User",
                        LastName = "Mobile",
                        Email = "user@example.com",
                        Username = "mobile",
                        PhoneNumber = "062222222",
                        PasswordHash = PasswordHelper.SetPassword("test"),
                        CityId = 3,
                        RoleId = 2,
                        IsActive = true
                    }
                );
                context.SaveChanges();
            }

            // 7. Working spaces
            if (!context.WorkingSpaces.Any())
            {
                context.WorkingSpaces.AddRange(
                    new WorkingSpace
                    {
                        Name = "Tech Hub Sarajevo",
                        Description = "Modern coworking space in the center of Sarajevo",
                        CityId = 1,
                        Capacity = 50,
                        Price = 25,
                        WorkspaceTypeId = 1,
                        WorkingSpaceStatusId = 1,
                        CreatedBy = 1 
                    },
                    new WorkingSpace
                    {
                        Name = "Zagreb BizLab",
                        Description = "Space for startup and freelancers in Zagreb",
                        CityId = 3,
                        Capacity = 40,
                        Price = 30,
                        WorkspaceTypeId = 2,
                        WorkingSpaceStatusId = 1,
                        CreatedBy = 1
                    }
                );
                context.SaveChanges();
            }

            // 8. Resources
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

            // 9. Reservation statuses
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

            // 10. Payment methods
            if (!context.PaymentMethods.Any())
            {
                context.PaymentMethods.AddRange(
                    new PaymentMethod { PaymentMethodName = "Credit Card" },
                    new PaymentMethod { PaymentMethodName = "PayPal" },
                    new PaymentMethod { PaymentMethodName = "Cash" }
                );
                context.SaveChanges();
            }
        }
    }
}
