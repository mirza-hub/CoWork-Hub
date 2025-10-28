using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using MapsterMapper;

namespace CoWorkHub.Services.Services
{
    public class WorkingSpaceService : BaseCRUDService<Model.WorkingSpace, WorkingSpaceSearchObject, Database.WorkingSpace, WorkingSpaceInsertRequest, WorkingSpaceUpdateRequest>, IWorkingSpaceService
    {
        public WorkingSpaceService(_210095Context context, IMapper mapper) 
            : base(context, mapper)  {  }

        public override IQueryable<WorkingSpace> AddFilter(WorkingSpaceSearchObject search, IQueryable<WorkingSpace> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.NameFTS))
                query = query.Where(x => x.Name.ToLower().Contains(search.NameFTS.ToLower()));
            
            if (search.CityId.HasValue)
                query = query.Where(x => x.CityId == search.CityId.Value);

            if (search.WorkspaceTypeId.HasValue)
                query = query.Where(x => x.WorkspaceTypeId == search.WorkspaceTypeId.Value);

            if (search.WorkingSpaceStatusId.HasValue)
                query = query.Where(x => x.WorkingSpaceStatusId == search.WorkingSpaceStatusId.Value);

            if (search.CapacityGTE.HasValue)
                query = query.Where(x => x.Capacity >= search.CapacityGTE.Value);

            if (search.CapacityLTE.HasValue)
                query = query.Where(x => x.Capacity <= search.CapacityLTE.Value);

            if (search.PriceGTE.HasValue)
                query = query.Where(x => x.Price >= search.PriceGTE.Value);

            if (search.PriceLTE.HasValue)
                query = query.Where(x => x.Price <= search.PriceLTE.Value);

            return query;
        }

        public override void BeforeInsert(WorkingSpaceInsertRequest request, WorkingSpace entity)
        {
            base.BeforeInsert(request, entity);
            entity.CreatedBy = 1; //SAD ZA SAD NEK OSTANE KEC DOK SE NE IMPLEMENTIRA LOGOVANJE KORISNIKA
            entity.CreatedAt = DateTime.UtcNow;
        }

        public override void BeforeUpdate(WorkingSpaceUpdateRequest request, WorkingSpace entity)
        {
            base.BeforeUpdate(request, entity);
            entity.ModifiedAt = DateTime.UtcNow;
            entity.ModifiedBy = 1; //SAD ZA SAD NEK OSTANE KEC DOK SE NE IMPLEMENTIRA LOGOVANJE KORISNIKA
        }
    }
}
