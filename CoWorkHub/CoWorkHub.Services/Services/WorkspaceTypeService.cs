using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;

namespace CoWorkHub.Services.Services
{
    public class WorkspaceTypeService : BaseCRUDService<Model.WorkspaceType, WorkspaceTypeSearchObject, WorkspaceType, WorkspaceTypeInsertRequest, WorkspaceTypeUpdateRequest>, IWorkspaceTypeService
    {
        public WorkspaceTypeService(_210095Context context, IMapper mapper) 
            : base(context, mapper)
        { }

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
    }
}
