using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;

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

            if (search.RoleId.HasValue)
                query = query.Where(x => x.RoleId == search.RoleId.Value);

            if (search.IsActive.HasValue)
                query = query.Where(x => x.IsActive == search.IsActive.Value);

            if (search.IsDeleted.HasValue)
                query = query.Where(x => x.IsDeleted == search.IsDeleted.Value);

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

            entity.PasswordSalt = _passwordService.GenerateSalt();
            entity.PasswordHash = _passwordService.GenerateHash(entity.PasswordSalt, request.Password);
            entity.RoleId = 2;
            entity.IsActive = true;
            entity.CreatedAt = DateTime.UtcNow;
        }
    }
}
