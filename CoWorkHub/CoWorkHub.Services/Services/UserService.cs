using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;

namespace CoWorkHub.Services.Services
{
    public class UserService : BaseCRUDService<Model.User, UserSearchObject, Database.User, UserInsertRequest, UserUpdateRequest>, IUserService
    {
        private readonly IPasswordService _passwordService;

        public UserService(_210095Context context, 
            IMapper mapper, 
            IPasswordService passwordService)
            : base(context, mapper) 
        {
            _passwordService = passwordService;
        }

        public override IQueryable<User> AddFilter(UserSearchObject search, IQueryable<User> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search?.FirstNameGTE))
                query = query.Where(x => x.FirstName.ToLower().StartsWith(search.FirstNameGTE.ToLower()));

            if (!string.IsNullOrWhiteSpace(search?.LastNameGTE))
                query = query.Where(x => x.LastName.ToLower().StartsWith(search.LastNameGTE.ToLower()));

            if (!string.IsNullOrWhiteSpace(search?.UsernameGTE))
                query = query.Where(x => x.Username.ToLower().StartsWith(search.UsernameGTE.ToLower()));

            if (!string.IsNullOrWhiteSpace(search?.Email))
                query = query.Where(x => x.Email == search.Email);

            if (search.CityId.HasValue)
                query = query.Where(x => x.CityId == search.CityId.Value);

            if (search.IsUserRolesIncluded == true)
                query = query.Include(x => x.UserRoles).ThenInclude(x => x.Role);

            if (search.IsActive.HasValue)
                query = query.Where(x => x.IsActive == search.IsActive.Value);

            return query;
        }

        public override void BeforeInsert(UserInsertRequest request, User entity)
        {
            base.BeforeInsert(request, entity);

            if (request.Password != request.PasswordConfirm)
                throw new UserException("Password and onfirmation password must match.");

            if (Context.Users.Any(x => x.Username.ToLower() == request.Username.ToLower()))
                throw new UserException("User with this username is already registered.");

            if (Context.Users.Any(x => x.Email.ToLower() == request.Email.ToLower()))
                throw new UserException("User with this email is already registered.");

            entity.CreatedAt = DateTime.UtcNow;
            entity.PasswordSalt = _passwordService.GenerateSalt();
            entity.PasswordHash = _passwordService.GenerateHash(entity.PasswordSalt, request.Password);
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

            return Mapper.Map<Model.User>(entity);
        }

        public override void BeforeUpdate(UserUpdateRequest request, User entity)
        {
            base.BeforeUpdate(request, entity);

            if (!string.IsNullOrWhiteSpace(request.Password) || !string.IsNullOrWhiteSpace(request.PasswordConfirm))
            {
                if (request.Password != request.PasswordConfirm)
                {
                    throw new UserException("Password and confirmation password must match.");
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
                    throw new UserException("User with this email already exists.");
                }
            }

            if (!string.IsNullOrWhiteSpace(entity.Username))
            {
                var existingUserByUsername = Context.Users
                    .FirstOrDefault(x => x.Username.ToLower() == entity.Username.ToLower() && x.UsersId != entity.UsersId);

                if (existingUserByUsername != null)
                {
                    throw new UserException("User with this username already exists.");
                }
            }

            entity.ModifiedAt = DateTime.UtcNow;
        }
    }
}
