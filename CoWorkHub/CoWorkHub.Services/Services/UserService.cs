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

namespace CoWorkHub.Services.Services
{
    public class UserService : BaseCRUDService<Model.User, UserSearchObject, Database.User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        private readonly IPasswordService _passwordService;
        private readonly IRabbitMqService _rabbitMqService;

        public UserService(_210095Context context, 
            IMapper mapper, 
            IPasswordService passwordService,
            IRabbitMqService rabbitMqService)
            : base(context, mapper) 
        {
            _passwordService = passwordService;
            _rabbitMqService = rabbitMqService;
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

            if (!string.IsNullOrWhiteSpace(request.Password) || !string.IsNullOrWhiteSpace(request.PasswordConfirm))
            {
                if (request.Password != request.PasswordConfirm)
                {
                    throw new UserException("Lozinka i lozinka potvrda se moraju podudarati");
                }

                entity.PasswordSalt = _passwordService.GenerateSalt();
                entity.PasswordHash = _passwordService.GenerateHash(entity.PasswordSalt, request.Password);
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
    }
}
