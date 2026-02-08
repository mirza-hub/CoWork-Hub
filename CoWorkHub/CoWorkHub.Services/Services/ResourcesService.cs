using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using Microsoft.Extensions.Logging;

namespace CoWorkHub.Services.Services
{
    public class ResourcesService : BaseCRUDService<Model.Resource, ResourcesSearchObject, Database.Resource, ResourcesInsertRequest, ResourcesUpdateRequest>, IResourcesService
    {
        private readonly ILogger<ResourcesService> _logger;
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;

        public ResourcesService(_210095Context context,
            IMapper mapper,
            ILogger<ResourcesService> logger,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService)
            : base(context, mapper)
        {
            _logger = logger;
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
        }

        public override IQueryable<Resource> AddFilter(ResourcesSearchObject search, IQueryable<Resource> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.ResourceNameGTE))
            {
                query = query.Where(x => x.ResourceName.ToLower().StartsWith(search.ResourceNameGTE.ToLower()));
            }

            return query;
        }

        public override void BeforeInsert(ResourcesInsertRequest request, Resource entity)
        {
            base.BeforeInsert(request, entity);

            _logger.LogInformation($"Adding Resource: {entity.ResourceName}");

            if (string.IsNullOrWhiteSpace(request.ResourceName))
                throw new UserException("Naziv resursa ne smije biti prazan.");

            var existingResource = Context.Resources
                .FirstOrDefault(x => x.ResourceName.ToLower() == request.ResourceName.ToLower());

            if (existingResource != null)
            {
                throw new UserException("Resurs sa ovim imenom već postoji u bazi.");
            }

            entity.IsDeleted = false;
            entity.CreatedAt = DateTime.UtcNow;
        }

        public override void BeforeUpdate(ResourcesUpdateRequest request, Resource entity)
        {
            base.BeforeUpdate(request, entity);

            if (string.IsNullOrWhiteSpace(request.ResourceName))
                throw new UserException("Naziv resursa ne smije biti prazan.");

            var existingResource = Context.Resources
                .FirstOrDefault(x => x.ResourceName.ToLower() == request.ResourceName.ToLower() && x.ResourcesId != entity.ResourcesId);

            if (existingResource != null)
            {
                throw new UserException("Resurs sa ovim imenom već postoji u bazi.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
        }

        public Model.Resource RestoreResource(int id)
        {
            var set = Context.Set<Database.Resource>();

            var entity = set.Find(id);

            if (entity == null)
                throw new UserException("Resurs nije pronađen.");

            if (entity.IsDeleted == false)
                throw new UserException("Resurs nije moguće vratiti jer nije obrisan.");

            entity.IsDeleted = false;
            entity.DeletedAt = null;

            Context.SaveChanges();

            return Mapper.Map<Model.Resource>(entity);
        }

        public override void AfterInsert(ResourcesInsertRequest request, Resource entity)
        {
            base.AfterInsert(request, entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CREATE",
            "Resource",
            $"Kreiran novi resurs {entity.ResourcesId}");
        }

        public override void AfterUpdate(ResourcesUpdateRequest request, Resource entity)
        {
            base.AfterUpdate(request, entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "UPDATE",
            "Resource",
            $"Ažuriran resurs {entity.ResourcesId}");
        }

        public override void AfterDelete(Resource entity)
        {
            base.AfterDelete(entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "DELETE",
            "Resource",
            $"Obrisan resurs {entity.ResourcesId}");
        }
    }
}