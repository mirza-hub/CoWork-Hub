using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class RoleService : BaseCRUDService<Model.Role, RoleSearchObject, Database.Role, RoleInsertRequest, RoleUpdateRequest>, IRoleService
    {
        private readonly ILogger<RoleService> _logger;
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;

        public RoleService(_210095Context context, 
            IMapper mapper,
            ILogger<RoleService> logger,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService) 
            : base(context, mapper)
        { 
            _logger = logger;
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
        }

        public override IQueryable<Role> AddFilter(RoleSearchObject search, IQueryable<Role> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.RoleNameGTE))
            {
                query = query.Where(x => x.RoleName.ToLower().StartsWith(search.RoleNameGTE.ToLower()));
            }

            return query;
        }

        public override void BeforeInsert(RoleInsertRequest request, Role entity)
        {
            base.BeforeInsert(request, entity);

            _logger.LogInformation($"Adding Role: {entity.RoleName}");

            var existingRole = Context.Roles
                .FirstOrDefault(x => x.RoleName.ToLower() == request.RoleName.ToLower());

            if (existingRole != null)
            {
                throw new UserException("Uloga sa ovim imenom već postoji u bazi.");
            }

            entity.IsDeleted = false;
        }

        public override void BeforeUpdate(RoleUpdateRequest request, Role entity)
        {
            base.BeforeUpdate(request, entity);

            var existingRole = Context.Roles
                .FirstOrDefault(x => x.RoleName.ToLower() == request.RoleName.ToLower() && x.RolesId != entity.RolesId);

            if (existingRole != null)
            {
                throw new UserException("Uloga sa ovim imenom već postoji u bazi.");
            }
        }

        public Model.Role RestoreRole(int id)
        {
            var set = Context.Set<Database.Role>();

            var entity = set.Find(id);

            if (entity == null)
                throw new UserException("Uloga nije pronađen.");

            if (entity.IsDeleted == false)
                throw new UserException("Ulogu nije moguće vratiti jer nije obrisana.");

            entity.IsDeleted = false;
            entity.DeletedAt = null;

            Context.SaveChanges();

            return Mapper.Map<Model.Role>(entity);
        }

        public override void AfterInsert(RoleInsertRequest request, Role entity)
        {
            base.AfterInsert(request, entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CREATE",
            "Role",
            $"Kreirana nova rola {entity.RolesId}");
        }

        public override void AfterUpdate(RoleUpdateRequest request, Role entity)
        {
            base.AfterUpdate(request, entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "UPDATE",
            "Role",
            $"Ažurirana Rola {entity.RolesId}");
        }

        public override void AfterDelete(Role entity)
        {
            base.AfterDelete(entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "DELETE",
            "Role",
            $"Obrisana Rola {entity.RolesId}");
        }
    }
}
