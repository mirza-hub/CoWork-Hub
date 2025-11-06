using Azure.Core;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using CoWorkHub.Services.WorkingSpaceStateMachine;
using MapsterMapper;

namespace CoWorkHub.Services.Services
{
    public class WorkingSpaceService : BaseCRUDService<Model.WorkingSpace, WorkingSpaceSearchObject, Database.WorkingSpace, WorkingSpaceInsertRequest, WorkingSpaceUpdateRequest>, IWorkingSpaceService
    {
        public BaseWorkingSpaceState BaseWorkingSpaceState { get; set; }
        public WorkingSpaceService(_210095Context context, IMapper mapper, BaseWorkingSpaceState baseWorkingSpaceState) 
            : base(context, mapper) 
        {
            BaseWorkingSpaceState = baseWorkingSpaceState;
        }

        public override IQueryable<WorkingSpace> AddFilter(WorkingSpaceSearchObject search, IQueryable<WorkingSpace> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.NameFTS))
                query = query.Where(x => x.Name.ToLower().Contains(search.NameFTS.ToLower()));
            
            if (search.CityId.HasValue)
                query = query.Where(x => x.CityId == search.CityId.Value);

            if (search.WorkspaceTypeId.HasValue)
                query = query.Where(x => x.WorkspaceTypeId == search.WorkspaceTypeId.Value);

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

        public override Model.WorkingSpace Insert(WorkingSpaceInsertRequest request)
        {
            var state = BaseWorkingSpaceState.CreateState("initial");
            return state.Insert(request);
        }

        public override Model.WorkingSpace Update(int id, WorkingSpaceUpdateRequest request)
        {
            var entity = GetById(id);
            var state = BaseWorkingSpaceState.CreateState(entity.StateMachine);
            return state.Update(id, request);
        }

        public Model.WorkingSpace Activate(int id)
        {
            var entity = GetById(id);
            var state = BaseWorkingSpaceState.CreateState(entity.StateMachine);
            return state.Activate(id);
        }

        public Model.WorkingSpace Edit(int id)
        {
            var entity = GetById(id);
            var state = BaseWorkingSpaceState.CreateState(entity.StateMachine);
            return state.Edit(id);
        }

        public Model.WorkingSpace Hide(int id)
        {
            var entity = GetById(id);
            var state = BaseWorkingSpaceState.CreateState(entity.StateMachine);
            return state.Hide(id);
        }

        public Model.WorkingSpace SetMaintenance(int id)
        {
            var entity = GetById(id);
            var state = BaseWorkingSpaceState.CreateState(entity.StateMachine);
            return state.SetMaintenance(id);
        }

        public override void Delete(int id)
        {
            var entity = GetById(id);
            var state = BaseWorkingSpaceState.CreateState(entity.StateMachine);
            state.Delete(id);
        }

        public Model.WorkingSpace Restore(int id)
        {
            var entity = GetById(id);
            var state = BaseWorkingSpaceState.CreateState(entity.StateMachine);
            return state.Restore(id);
        }

        public List<string> AllowedActions(int id)
        {
            if (id <= 0)
            {
                var state = BaseWorkingSpaceState.CreateState("initial");
                return state.AllowedActions(null);
            }
            else
            {
                var entity = Context.WorkingSpaces.Find(id);
                var state = BaseWorkingSpaceState.CreateState(entity.StateMachine);
                return state.AllowedActions(entity);
            }
        }
    }
}
