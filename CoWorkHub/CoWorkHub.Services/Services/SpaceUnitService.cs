using Azure.Core;
using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using CoWorkHub.Services.WorkingSpaceStateMachine;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class SpaceUnitService : BaseCRUDService<Model.SpaceUnit, SpaceUnitSearchObject, Database.SpaceUnit, SpaceUnitInsertRequest, SpaceUnitUpdateRequest>, ISpaceUnitService
    {
        public BaseSpaceUnitState BaseSpaceUnitState { get; set; }

        public SpaceUnitService(_210095Context context, IMapper mapper, BaseSpaceUnitState baseSpaceUnitStat)
            : base(context, mapper)
        {
            BaseSpaceUnitState = baseSpaceUnitStat;
        }

        public override IQueryable<SpaceUnit> AddFilter(SpaceUnitSearchObject search, IQueryable<SpaceUnit> query)
        {
            query = base.AddFilter(search, query);

            if (search.WorkingSpaceId.HasValue)
                query = query.Where(x => x.WorkingSpaceId == search.WorkingSpaceId);

            query = query.Where(x => x.StateMachine == "active");

            if (!string.IsNullOrWhiteSpace(search.Name))
                query = query.Where(x => x.Name.Contains(search.Name));

            if (search.WorkspaceTypeId.HasValue)
                query = query.Where(x => x.WorkspaceTypeId == search.WorkspaceTypeId);

            if (search.CityId.HasValue)
                query = query.Where(x => x.WorkingSpace.CityId == search.CityId);

            if (search.PriceFrom.HasValue)
                query = query.Where(x => x.PricePerDay >= search.PriceFrom);

            if (search.PriceTo.HasValue)
                query = query.Where(x => x.PricePerDay <= search.PriceTo);

            if (search.CapacityFrom.HasValue)
                query = query.Where(x => x.Capacity >= search.CapacityFrom);

            if (search.CapacityTo.HasValue)
                query = query.Where(x => x.Capacity <= search.CapacityTo);

            if (search.From != null && search.To != null)
            {
                var from = search.From.Value;
                var to = search.To.Value;
                var requestedPeopleCount = search.PeopleCount ?? 1;

                query = query.Where(su =>
                    su.WorkspaceTypeId == 1 ? ((Context.Reservations.Where(r =>
                        r.SpaceUnitId == su.SpaceUnitId &&
                        !r.IsDeleted &&
                        r.StartDate < to &&
                        r.EndDate > from
                    ).Sum(r => (int?)r.PeopleCount) ?? 0) + requestedPeopleCount <= su.Capacity) 
                    : ((su.Capacity - (Context.Reservations.Where(r =>
                    r.SpaceUnitId == su.SpaceUnitId &&
                    !r.IsDeleted &&
                    r.StartDate < to &&
                    r.EndDate > from)
                .Sum(r => (int?)r.PeopleCount) ?? 0)) >= requestedPeopleCount));
            }

            if (search.IncludeWorkingSpace)
                query = query.Include(x => x.WorkingSpace)
                    .ThenInclude(r => r.City);

            if (search.IncludeWorkspaceType)
                query = query.Include(x => x.WorkspaceType);

            if (search.IncludeResources)
                query = query.Include(x => x.SpaceUnitResources)
                    .ThenInclude(r => r.Resources);

            if (search.IncludeImages)
                query = query.Include(x => x.SpaceUnitImages);

            return query;
        }

        public override Model.SpaceUnit Insert(SpaceUnitInsertRequest request)
        {
            var state = BaseSpaceUnitState.CreateState("initial");
            return state.Insert(request);
        }

        public override Model.SpaceUnit Update(int id, SpaceUnitUpdateRequest request)
        {
            var entity = GetById(id);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            return state.Update(id, request);
        }

        public override void Delete(int id)
        {
            var entity = GetById(id);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            state.Delete(id);
        }

        public Model.SpaceUnit Activate(int id)
        {
            var entity = GetById(id);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            return state.Activate(id);
        }

        public Model.SpaceUnit Edit(int id)
        {
            var entity = GetById(id);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            return state.Edit(id);
        }

        public Model.SpaceUnit Hide(int id)
        {
            var entity = GetById(id);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            return state.Hide(id);
        }

        public Model.SpaceUnit SetMaintenance(int id)
        {
            var entity = GetById(id);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            return state.SetMaintenance(id);
        }

        public Model.SpaceUnit Restore(int id)
        {
            var entity = GetById(id);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            return state.Restore(id);
        }

        public List<string> AllowedActions(int id)
        {
            if (id <= 0)
            {
                var state = BaseSpaceUnitState.CreateState("initial");
                return state.AllowedActions(null);
            }
            else
            {
                var entity = Context.SpaceUnits.Find(id);
                var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
                return state.AllowedActions(entity);
            }
        }
    }
}