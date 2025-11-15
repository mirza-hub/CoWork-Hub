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

        public SpaceUnitResourceService(
            _210095Context context, 
            IMapper mapper,
            ICurrentUserService currentUserService) 
            : base(context, mapper)
        {
            _currentUserService = currentUserService;
        }

        public override IQueryable<SpaceUnitResource> AddFilter(SpaceUnitResourcesSearchObject search, IQueryable<SpaceUnitResource> query)
        {
            query = base.AddFilter(search, query);

            if (search.SpaceUnitId.HasValue)
                query = query.Where(x => x.SpaceUnitId == search.SpaceUnitId);

            if (search.ResourceId.HasValue)
                query = query.Where(x => x.ResourcesId == search.ResourceId);

            if (search.IncludeSpaceUnit)
                query = query.Include(x => x.SpaceUnit);

            if (search.IncludeResource)
                query = query.Include(x => x.Resources);

            return query;

        }

        public override void BeforeInsert(SpaceUnitResourcesInsertRequest request, SpaceUnitResource entity)
        {
            base.BeforeInsert(request, entity);

            if (!Context.SpaceUnits.Any(x => x.SpaceUnitId == request.SpaceUnitId && !x.IsDeleted))
                throw new UserException("SpaceUnit does not exist.");

            if (!Context.Resources.Any(x => x.ResourcesId == request.ResourcesId && !x.IsDeleted))
                throw new UserException("Resource does not exist.");

            bool exists = Context.SpaceUnitResources.Any(x =>
                x.SpaceUnitId == request.SpaceUnitId &&
                x.ResourcesId == request.ResourcesId &&
                !x.IsDeleted);

            if (exists)
                throw new UserException("This resource is already assigned to this SpaceUnit.");

            entity.CreatedAt = DateTime.UtcNow;
            entity.CreatedBy = (int)_currentUserService.GetUserId();
        }

        public override void BeforeUpdate(SpaceUnitResourcesUpdateRequest request, SpaceUnitResource entity)
        {
            base.BeforeUpdate(request, entity);

            if (request.ResourcesId.HasValue)
            {
                if (!Context.Resources.Any(x => x.ResourcesId == request.ResourcesId && !x.IsDeleted))
                    throw new UserException("Resource does not exist.");

                bool duplicate = Context.SpaceUnitResources.Any(x =>
                    x.SpaceUnitId == entity.SpaceUnitId &&
                    x.ResourcesId == request.ResourcesId &&
                    x.SpaceResourcesId != entity.SpaceResourcesId &&
                    !x.IsDeleted);

                if (duplicate)
                    throw new UserException("This resource is already assigned to this SpaceUnit.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.ModifiedBy = (int)_currentUserService.GetUserId();

        }
    }
}
