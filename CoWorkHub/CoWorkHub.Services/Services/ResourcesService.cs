using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;

namespace CoWorkHub.Services.Services
{
    public class ResourcesService : BaseCRUDService<Model.Resource, ResourcesSearchObject, Database.Resource, ResourcesInsertRequest, ResourcesUpdateRequest>, IResourcesService
    {
        public ResourcesService(_210095Context context, IMapper mapper)
            : base(context, mapper) { }

        public override IQueryable<Resource> AddFilter(ResourcesSearchObject search, IQueryable<Resource> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.ResourceNameGTE))
            {
                query = query.Where(x => x.ResourceName.ToLower().StartsWith(search.ResourceNameGTE.ToLower()));
            }

            return query;
        }
    }
}