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
    public class WorkspaceTypeService : BaseCRUDService<Model.WorkspaceType, WorkspaceTypeSearchObject, WorkspaceType, WorkspaceTypeInsertRequest, WorkspaceTypeUpdateRequest>, IWorkspaceTypeService
    {
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;

        public WorkspaceTypeService(_210095Context context, 
            IMapper mapper,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService
            ) 
            : base(context, mapper)
        {
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
        }

        public override IQueryable<WorkspaceType> AddFilter(WorkspaceTypeSearchObject search, IQueryable<WorkspaceType> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.TypeNameGTE))
            {
                query = query.Where(x => x.TypeName.ToLower().StartsWith(search.TypeNameGTE.ToLower()));
            }

            return query;
        }

        public override void BeforeInsert(WorkspaceTypeInsertRequest request, WorkspaceType entity)
        {
            base.BeforeInsert(request, entity);

            var existingWorkspaceType = Context.WorkspaceTypes
                .FirstOrDefault(x => 
                x.TypeName.ToLower() == request.TypeName.ToLower() &&
                x.WorkspaceTypeId != entity.WorkspaceTypeId);

            if (existingWorkspaceType != null)
            {
                if (existingWorkspaceType.TypeName.Equals(request.TypeName, StringComparison.OrdinalIgnoreCase))
                    throw new UserException("Tip prostora sa ovim imenom već postoji u bazi.");
            }

            entity.CreatedAt = DateTime.UtcNow;
        }

        public override void BeforeUpdate(WorkspaceTypeUpdateRequest request, WorkspaceType entity)
        {
            base.BeforeUpdate(request, entity);

            var existingWorkspaceType = Context.WorkspaceTypes
                .FirstOrDefault(x => x.TypeName.ToLower() == request.TypeName.ToLower());

            if (existingWorkspaceType != null)
            {
                throw new UserException("Tip prostora sa ovim imenom već postoji u bazi.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
        }

        public Model.WorkspaceType RestoreWorkspaceType(int id)
        {
            var set = Context.Set<Database.WorkspaceType>();

            var entity = set.Find(id);

            if (entity == null)
                throw new UserException("Tip prostora nije pronađen.");

            if (entity.IsDeleted == false)
                throw new UserException("Tip prostora nije moguće vratiti jer nije obrisan.");

            entity.IsDeleted = false;
            entity.DeletedAt = null;

            Context.SaveChanges();

            return Mapper.Map<Model.WorkspaceType>(entity);
        }

        public override void AfterInsert(WorkspaceTypeInsertRequest request, WorkspaceType entity)
        {
            base.AfterInsert(request, entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CREATE",
            "WorkspaceType",
            $"Tip prostora kreiran {entity.WorkspaceTypeId}");
        }

        public override void AfterUpdate(WorkspaceTypeUpdateRequest request, WorkspaceType entity)
        {
            base.AfterUpdate(request, entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CREATE",
            "WorkspaceType",
            $"Tip prostora ažuriran {entity.WorkspaceTypeId}");
        }

        public override void AfterDelete(WorkspaceType entity)
        {
            base.AfterDelete(entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CREATE",
            "WorkspaceType",
            $"Tip prostora obrisan {entity.WorkspaceTypeId}");
        }
    }
}
