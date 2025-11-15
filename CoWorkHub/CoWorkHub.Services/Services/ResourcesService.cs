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
    public class ResourcesService : BaseCRUDService<Model.Resource, ResourcesSearchObject, Database.Resource, ResourcesInsertRequest, ResourcesUpdateRequest>, IResourcesService
    {
        public ResourcesService(_210095Context context, IMapper mapper)
            : base(context, mapper) 
        { }

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

            var existingResource = Context.Resources
                .FirstOrDefault(x => x.ResourceName.ToLower() == request.ResourceName.ToLower());

            if (existingResource != null)
            {
                throw new UserException("A resource with this name already exists in the database.");
            }

            entity.IsDeleted = false;
            entity.CreatedAt = DateTime.UtcNow;
        }

        public override void BeforeUpdate(ResourcesUpdateRequest request, Resource entity)
        {
            base.BeforeUpdate(request, entity);

            var existingResource = Context.Resources
                .FirstOrDefault(x => x.ResourceName.ToLower() == request.ResourceName.ToLower());

            if (existingResource != null)
            {
                throw new UserException("Another resource with this name already exists in the database.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
        }
    }
}