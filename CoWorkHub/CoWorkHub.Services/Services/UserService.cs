using Azure.Core;
using CoWorkHub.Model;
using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Messages;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.RabbitMqService;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Text.RegularExpressions;

namespace CoWorkHub.Services.Services
{
    public class UserService : BaseCRUDService<Model.User, UserSearchObject, Database.User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        private readonly ILogger<UserService> _logger;
        private readonly IPasswordService _passwordService;
        private readonly IRabbitMqService _rabbitMqService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;

        public UserService(_210095Context context, 
            IMapper mapper, 
            IPasswordService passwordService,
            IRabbitMqService rabbitMqService,
            ILogger<UserService> logger,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService
            )
            : base(context, mapper) 
        {
            _passwordService = passwordService;
            _rabbitMqService = rabbitMqService;
            _logger = logger;
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
        }

        public override IQueryable<Database.User> AddFilter(UserSearchObject search, IQueryable<Database.User> query)
        {
            query = base.AddFilter(search, query);

            if (search.UsersId.HasValue)
                query = query.Where(x => x.UsersId == search.UsersId.Value);

            if (!string.IsNullOrWhiteSpace(search?.FTS))
                query = query.Where(x => x.FirstName.ToLower().StartsWith(search.FTS.ToLower()) 
                || x.LastName.ToLower().StartsWith(search.FTS.ToLower()) 
                || x.Username.ToLower().StartsWith(search.FTS.ToLower()));

            if (!string.IsNullOrWhiteSpace(search?.Email))
                query = query.Where(x => x.Email.ToLower().Contains(search.Email.ToLower()));

            if (search.CityId.HasValue)
                query = query.Where(x => x.CityId == search.CityId.Value);

            if (search.IsUserRolesIncluded == true)
                query = query.Include(x => x.UserRoles).ThenInclude(x => x.Role);

            if (search.IsActive.HasValue)
                query = query.Where(x => x.IsActive == search.IsActive.Value);

            return query;
        }

        public override PagedResult<Model.User> GetPaged(UserSearchObject search)
        {
            var pagedResult = base.GetPaged(search);

            foreach (var user in pagedResult.ResultList)
            {
                if (user.ProfileImage != null)
                    user.ProfileImageBase64 = Convert.ToBase64String(user.ProfileImage);
            }

            return pagedResult;
        }
        public override Model.User GetById(int id)
        {
            var user = base.GetById(id);

            if (user?.ProfileImage != null)
                user.ProfileImageBase64 = Convert.ToBase64String(user.ProfileImage);

            return user;
        }

        public override void BeforeInsert(UserInsertRequest request, Database.User entity)
        {
            base.BeforeInsert(request, entity);

            _logger.LogInformation($"Adding User: {entity.FirstName} {entity.LastName}");

            ValidateUserInsert(request);

            if (request.Password != request.PasswordConfirm)
                throw new UserException("Lozinka i lozinka potvrda se moraju podudarati");

            if (Context.Users.Any(x => x.Username.ToLower() == request.Username.ToLower()))
                throw new UserException("Korisnik sa ovim korisničkim imenom je već registrovan");

            if (Context.Users.Any(x => x.Email.ToLower() == request.Email.ToLower()))
                throw new UserException("Korisnik sa ovim emailom je već registrovan");

            entity.CreatedAt = DateTime.UtcNow;
            entity.PasswordSalt = _passwordService.GenerateSalt();
            entity.PasswordHash = _passwordService.GenerateHash(entity.PasswordSalt, request.Password);

            _rabbitMqService.SendAnEmail(new EmailDTO
            {
                EmailTo = entity.Email,
                Message = $"Poštovani<br>" +
                       $"Korisnicko ime: {entity.Username}<br>" +
                       $"Vaša registracija je uspješna<br>" +
                       $"Srdačan pozdrav",
                ReceiverName = entity.FirstName + " " + entity.LastName,
                Subject = "Registracija"
            });
        }

        public override void AfterInsert(UserInsertRequest request, Database.User entity)
        {
            var roles = Context.Roles.FirstOrDefault(x=>x.RoleName== "User");
            var newUserRole = Context.UserRoles.Add(new Database.UserRole
            {
                UserId = entity.UsersId,
                RoleId = roles.RolesId
            });

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CREATE",
            "User",
            $"Kreiran novi user {entity.UsersId}");

            Context.SaveChanges();

        }

        public Model.User Login(string username, string password)
        {
            var entity = Context.Users.Include(x=> x.UserRoles).ThenInclude(y=> y.Role).FirstOrDefault(x => x.Username == username);

            if (entity == null)
            {
                return null;
            }

            var hash = _passwordService.GenerateHash(entity.PasswordSalt, password);

            if (hash != entity.PasswordHash)
            {
                return null;
            }

            var user = Mapper.Map<Model.User>(entity);

            if (user.ProfileImage != null)
                user.ProfileImageBase64 = Convert.ToBase64String(user.ProfileImage);

            return user;
        }

        public override void BeforeUpdate(UserUpdateRequest request, Database.User entity)
        {
            base.BeforeUpdate(request, entity);
            if (!string.IsNullOrWhiteSpace(request.Password) ||
                !string.IsNullOrWhiteSpace(request.PasswordConfirm))
            {
                if (string.IsNullOrWhiteSpace(request.OldPassword))
                    throw new UserException("Morate unijeti staru lozinku");

                var oldHash = _passwordService.GenerateHash(
                    entity.PasswordSalt,
                    request.OldPassword
                );

                if (oldHash != entity.PasswordHash)
                    throw new UserException("Stara lozinka nije tačna");

                if (request.Password != request.PasswordConfirm)
                    throw new UserException("Lozinka i potvrda se moraju podudarati");

                if (request.Password.Length < 8 || request.Password.Length > 64)
                    throw new UserException("Lozinka mora imati 8–64 karaktera");

                entity.PasswordSalt = _passwordService.GenerateSalt();
                entity.PasswordHash = _passwordService.GenerateHash(
                    entity.PasswordSalt,
                    request.Password
                );
            }


            if (!string.IsNullOrWhiteSpace(entity.Email))
            {
                var existingUserByEmail = Context.Users
                    .FirstOrDefault(x => x.Email.ToLower() == entity.Email.ToLower() && x.UsersId != entity.UsersId);

                if (existingUserByEmail != null)
                {
                    throw new UserException("Korisnik sa ovim emailom je već registrovan");
                }
            }

            if (!string.IsNullOrWhiteSpace(entity.Username))
            {
                var existingUserByUsername = Context.Users
                    .FirstOrDefault(x => x.Username.ToLower() == entity.Username.ToLower() && x.UsersId != entity.UsersId);

                if (existingUserByUsername != null)
                {
                    throw new UserException("Korisnik sa ovim korisničkim imenom je već registrovan");
                }
            }

            if (string.IsNullOrEmpty(request.ProfileImageBase64))
            {
                entity.ProfileImage = null;
            }
            else
            {
                entity.ProfileImage = Convert.FromBase64String(request.ProfileImageBase64);
            }

            entity.ModifiedAt = DateTime.UtcNow;
        }

        public override void BeforeDelete(Database.User entity)
        {
            base.BeforeDelete(entity);

            entity.IsActive = false;
        }

        public Model.User UpdateForAdmin(int id, UserAdminUpdateRequest request)
        {
            var set = Context.Set<Database.User>();

            var entity = set.Find(id);

            if (entity == null)
                throw new UserException("Entitet nije pronađen.");

            entity.IsActive = (bool)request.IsActive;

            if (string.IsNullOrEmpty(request.ProfileImageBase64))
            {
                entity.ProfileImage = null;
            }
            else
            {
                entity.ProfileImage = Convert.FromBase64String(request.ProfileImageBase64);
            }

            if (request.RolesId != null)
            {
                var rolesToRemove = Context.UserRoles
                    .Where(ur => ur.UserId == id)
                    .ToList();

                Context.UserRoles.RemoveRange(rolesToRemove);

                foreach (var roleId in request.RolesId)
                {
                    entity.UserRoles.Add(new Database.UserRole
                    {
                        UserId = entity.UsersId,
                        RoleId = roleId
                    });
                }

                Context.SaveChanges();
            }

            var userWithRoles = Context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefault(u => u.UsersId == entity.UsersId);

            return Mapper.Map<Model.User>(userWithRoles);
        }

        public Model.PasswordResetRequest SendPasswordResetCode(PasswordResetRequestRequest request)
        {
            var user = Context.Users.FirstOrDefault(u => u.Email.ToLower() == request.Email.ToLower());

            if (user == null)
                throw new UserException("Korisnik sa ovim emailom ne postoji");

            var code = new Random().Next(100000, 999999).ToString();

            var resetRequest = new Database.PasswordResetRequest
            {
                UserId = user.UsersId,
                Code = code,
                CreatedAt = DateTime.UtcNow
            };

            Context.PasswordResetRequests.Add(resetRequest);
            Context.SaveChanges();

            _rabbitMqService.SendAnEmail(new EmailDTO
            {
                EmailTo = user.Email,
                Message = $"Vaš kod za reset lozinke: <b>{code}</b>",
                ReceiverName = $"{user.FirstName} {user.LastName}",
                Subject = "Reset lozinke"
            });

            return Mapper.Map<Model.PasswordResetRequest>(resetRequest);
        }

        public bool VerifyResetCode(string email, string code)
        {
            var user = Context.Users.FirstOrDefault(u => u.Email.ToLower() == email.ToLower());
            if (user == null) return false;

            var request = Context.PasswordResetRequests
                .Where(r => r.UserId == user.UsersId && !r.IsUsed)
                .OrderByDescending(r => r.CreatedAt)
                .FirstOrDefault();

            if (request == null) return false;
            if ((DateTime.UtcNow - request.CreatedAt).TotalMinutes > 10) return false;
            if (request.Code != code) return false;

            request.IsUsed = true;
            Context.SaveChanges();

            return true;
        }

        public void ResetPassword(string email, string newPassword, string newPasswordConfirm)
        {
            if (string.IsNullOrWhiteSpace(newPassword))
                throw new UserException("Lozinka je obavezna");

            if (newPassword.Length < 8 || newPassword.Length > 64)
                throw new UserException("Lozinka mora imati 8–64 karaktera");

            if (newPassword != newPasswordConfirm)
                throw new UserException("Lozinka i potvrda se ne poklapaju");

            var user = Context.Users.FirstOrDefault(u => u.Email.ToLower() == email.ToLower());
            if (user == null) throw new UserException("Korisnik ne postoji");

            user.PasswordSalt = _passwordService.GenerateSalt();
            user.PasswordHash = _passwordService.GenerateHash(user.PasswordSalt, newPassword);

            Context.SaveChanges();
        }

        public Model.User RestoreUser(int id)
        {
            var set = Context.Set<Database.User>();

            var entity = set.Find(id);

            if (entity == null)
                throw new UserException("Korisnik nije pronađen.");

            if (entity.IsDeleted == false)
                throw new UserException("Korisnika nije moguće vratiti jer nije obrisan.");

            entity.IsDeleted = false;
            entity.IsActive = true;
            entity.DeletedAt = null;

            Context.SaveChanges();

            return Mapper.Map<Model.User>(entity);
        }

        public override void AfterUpdate(UserUpdateRequest request, Database.User entity)
        {
            base.AfterUpdate(request, entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "UPDATE",
            "User",
            $"Korisnik ažuriran {entity.UsersId}");
        }

        public override void AfterDelete(Database.User entity)
        {
            base.AfterDelete(entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "DELETE",
            "User",
            $"Korisnik obrisan {entity.UsersId}");
        }

        private void ValidateUserInsert(UserInsertRequest request)
        {
            // Ime
            if (string.IsNullOrWhiteSpace(request.FirstName))
                throw new UserException("Ime je obavezno");

            if (request.FirstName.Length > 30)
                throw new UserException("Ime ne smije biti duže od 30 karaktera");

            if (!Regex.IsMatch(request.FirstName, @"^[a-zA-ZšđčćžŠĐČĆŽ]+([ -][a-zA-ZšđčćžŠĐČĆŽ]+)*$"))
                throw new UserException("Ime može sadržavati samo slova, razmak ili crtu");

            // Prezime
            if (string.IsNullOrWhiteSpace(request.LastName))
                throw new UserException("Prezime je obavezno");

            if (request.LastName.Length > 30)
                throw new UserException("Prezime ne smije biti duže od 30 karaktera");

            if (!Regex.IsMatch(request.LastName, @"^[a-zA-ZšđčćžŠĐČĆŽ]+([ -][a-zA-ZšđčćžŠĐČĆŽ]+)*$"))
                throw new UserException("Prezime može sadržavati samo slova, razmak ili crtu");

            // Email
            if (string.IsNullOrWhiteSpace(request.Email))
                throw new UserException("Email je obavezan");

            if (request.Email.Length > 100)
                throw new UserException("Email ne smije biti duži od 100 karaktera");

            if (!Regex.IsMatch(request.Email, @"^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$"))
                throw new UserException("Neispravan format emaila. Primjer: ime.prezime@gmail.com");

            // Username
            if (string.IsNullOrWhiteSpace(request.Username))
                throw new UserException("Korisničko ime je obavezno");

            if (request.Username.Length < 3 || request.Username.Length > 15)
                throw new UserException("Korisničko ime mora imati 3–15 karaktera");

            if (!Regex.IsMatch(request.Username, @"^[a-zA-Z0-9_-]+$"))
                throw new UserException("Korisničko ime može sadržavati samo slova, brojeve, _ i -");

            // Telefon
            if (string.IsNullOrWhiteSpace(request.PhoneNumber))
                throw new UserException("Broj telefona je obavezan");

            if (!Regex.IsMatch(request.PhoneNumber, @"^\+?[0-9]{6,15}$"))
                throw new UserException("Neispravan format telefona. Primjer: +38761234567");

            // Lozinka
            if (string.IsNullOrWhiteSpace(request.Password))
                throw new UserException("Lozinka je obavezna");

            if (request.Password.Length < 8 || request.Password.Length > 64)
                throw new UserException("Lozinka mora imati 8–64 karaktera");

            // Lozinka potvrda
            if (request.Password != request.PasswordConfirm)
                throw new UserException("Lozinka i potvrda lozinke se moraju podudarati");

            // Grad
            if (request.CityId <= 0 || !Context.Cities.Any(c => c.CityId == request.CityId))
                throw new UserException("Morate odabrati validan grad");

            // Provjera duplikata username i email
            if (Context.Users.Any(x => x.Username.ToLower() == request.Username.ToLower()))
                throw new UserException("Korisnik sa ovim korisničkim imenom je već registrovan");

            if (Context.Users.Any(x => x.Email.ToLower() == request.Email.ToLower()))
                throw new UserException("Korisnik sa ovim emailom je već registrovan");
        }
    }
}
