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
    public class SpaceUnitResourceService : BaseCRUDService<Model.SpaceUnitResources, SpaceUnitResourcesSearchObject, SpaceUnitResource, SpaceUnitResourcesInsertRequest, SpaceUnitResourcesUpdateRequest>, ISpaceUnitResourceService
    {
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;
        private readonly INotificationService _notificationService;

        public SpaceUnitResourceService(
            _210095Context context, 
            IMapper mapper,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService,
            INotificationService notificationService
            ) 
            : base(context, mapper)
        {
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
            _notificationService = notificationService;
        }

        public override IQueryable<SpaceUnitResource> AddFilter(SpaceUnitResourcesSearchObject search, IQueryable<SpaceUnitResource> query)
        {
            query = base.AddFilter(search, query);

            if (search.SpaceUnitId.HasValue)
                query = query.Where(x => x.SpaceUnitId == search.SpaceUnitId);

            if (search.ResourceId.HasValue)
                query = query.Where(x => x.ResourcesId == search.ResourceId);

            //if (search.IncludeSpaceUnit)
            //    query = query.Include(x => x.SpaceUnit);

            //if (search.IncludeResource)
            //    query = query.Include(x => x.Resources);

            return query;

        }

        public override void BeforeInsert(SpaceUnitResourcesInsertRequest request, SpaceUnitResource entity)
        {
            base.BeforeInsert(request, entity);

            if (!Context.SpaceUnits.Any(x => x.SpaceUnitId == request.SpaceUnitId && !x.IsDeleted))
                throw new UserException("Prostorna jedinica ne postoji.");

            if (!Context.Resources.Any(x => x.ResourcesId == request.ResourcesId && !x.IsDeleted))
                throw new UserException("Resurs ne postoji.");

            bool exists = Context.SpaceUnitResources.Any(x =>
                x.SpaceUnitId == request.SpaceUnitId &&
                x.ResourcesId == request.ResourcesId &&
                !x.IsDeleted);

            if (exists)
                throw new UserException("Ovaj resurs je već dodjeljen ovoj prostornoj jedinici.");

            entity.CreatedAt = DateTime.UtcNow;
            entity.CreatedBy = (int)_currentUserService.GetUserId();
        }

        public override void BeforeUpdate(SpaceUnitResourcesUpdateRequest request, SpaceUnitResource entity)
        {
            base.BeforeUpdate(request, entity);

            if (request.ResourcesId.HasValue)
            {
                if (!Context.Resources.Any(x => x.ResourcesId == request.ResourcesId && !x.IsDeleted))
                    throw new UserException("Resurs ne postoji.");

                bool duplicate = Context.SpaceUnitResources.Any(x =>
                    x.SpaceUnitId == entity.SpaceUnitId &&
                    x.ResourcesId == request.ResourcesId &&
                    x.SpaceResourcesId != entity.SpaceResourcesId &&
                    !x.IsDeleted);

                if (duplicate)
                    throw new UserException("Ovaj resurs je već dodjeljen ovoj prostornoj jedinici.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.ModifiedBy = (int)_currentUserService.GetUserId();
        }

        public override void AfterInsert(SpaceUnitResourcesInsertRequest request, SpaceUnitResource entity)
        {
            base.AfterInsert(request, entity);
            var resources = Context.SpaceUnitResources.Include(x => x.SpaceUnit).Include(x => x.Resources).FirstOrDefault(x => x.SpaceResourcesId == entity.SpaceResourcesId);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CREATE",
            "SpaceUnitResource",
            $"Dodan novi resurs {resources.Resources.ResourceName.ToUpper()} za prostor {resources.SpaceUnit.Name.ToUpper()}");
            _notificationService.Insert(new NotificationInsertRequest
            {
                UserId = _currentUserId,
                Message = $"Uspješno ste dodali resurs {resources.Resources.ResourceName} za prostor {resources.SpaceUnit.Name}."
            });
        }

        public override void AfterUpdate(SpaceUnitResourcesUpdateRequest request, SpaceUnitResource entity)
        {
            base.AfterUpdate(request, entity);
            var resources = Context.SpaceUnitResources.Include(x => x.SpaceUnit).Include(x => x.Resources).FirstOrDefault(x => x.SpaceResourcesId == entity.SpaceResourcesId);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "UPDATE",
            "SpaceUnitResource",
            $"Ažuriran novi resurs {resources.Resources.ResourceName.ToUpper()} za prostor {resources.SpaceUnit.Name.ToUpper()}");
        }

        public override void AfterDelete(SpaceUnitResource entity)
        {
            base.AfterDelete(entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            var resources = Context.SpaceUnitResources.Include(x => x.SpaceUnit).Include(x => x.Resources).FirstOrDefault(x => x.SpaceResourcesId == entity.SpaceResourcesId);
            _activityLogService.LogAsync(
            _currentUserId,
            "DELETE",
            "SpaceUnitResource",
            $"Obrisan resurs {resources.Resources.ResourceName.ToUpper()}  za prostor  {resources.SpaceUnit.Name.ToUpper()}");
            _notificationService.Insert(new NotificationInsertRequest
            {
                UserId = _currentUserId,
                Message = $"Uspješno ste obrisali resurs {resources.Resources.ResourceName} za prostor {resources.SpaceUnit.Name}."
            });
        }
    }
}
