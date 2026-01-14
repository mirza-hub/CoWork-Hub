using CoWorkHub.Model;
using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using CoWorkHub.Services.WorkingSpaceStateMachine;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System.Threading;

namespace CoWorkHub.Services.Services
{
    public class SpaceUnitService : BaseCRUDServiceAsync<Model.SpaceUnit, SpaceUnitSearchObject, Database.SpaceUnit, SpaceUnitInsertRequest, SpaceUnitUpdateRequest>, ISpaceUnitService
    {
        public BaseSpaceUnitState BaseSpaceUnitState { get; set; }

        public SpaceUnitService(_210095Context context, IMapper mapper, BaseSpaceUnitState baseSpaceUnitStat)
            : base(context, mapper)
        {
            BaseSpaceUnitState = baseSpaceUnitStat;
        }

        public override IQueryable<Database.SpaceUnit> AddFilter(SpaceUnitSearchObject search, IQueryable<Database.SpaceUnit> query)
        {
            query = base.AddFilter(search, query);

            if (search.SpaceUnitId.HasValue)
                query = query.Where(x => x.SpaceUnitId == search.SpaceUnitId);

            if (search.WorkingSpaceId.HasValue)
                query = query.Where(x => x.WorkingSpaceId == search.WorkingSpaceId);

            if (!search.IncludeAll)
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
                    su.WorkspaceTypeId == 1
                        ? (
                            (Context.Reservations
                                .Where(r =>
                                    r.SpaceUnitId == su.SpaceUnitId &&
                                    !r.IsDeleted &&
                                    (r.StateMachine == "pending" || r.StateMachine == "confirmed") &&
                                    r.StartDate < to &&
                                    r.EndDate > from
                                )
                                .Sum(r => (int?)r.PeopleCount) ?? 0
                            ) + requestedPeopleCount > su.Capacity
                        )
                        : !Context.Reservations.Any(r =>
                            r.SpaceUnitId == su.SpaceUnitId &&
                            !r.IsDeleted &&
                            (r.StateMachine == "pending" || r.StateMachine == "confirmed") &&
                            r.StartDate < to &&
                            r.EndDate > from
                        )
                );
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
        public override async Task<Model.SpaceUnit> InsertAsync(SpaceUnitInsertRequest request, CancellationToken cancellationToken = default)
        {
            var state = BaseSpaceUnitState.CreateState("initial");
            return await state.Insert(request, cancellationToken);
        }

        public override async Task<Model.SpaceUnit> UpdateAsync(int id, SpaceUnitUpdateRequest request, CancellationToken cancellationToken = default)
        {
            var entity = await GetByIdAsync(id, cancellationToken);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            return await state.Update(id, request, cancellationToken);
        }
        public override async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
        {
            var entity = await GetByIdAsync(id, cancellationToken);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            await state.Delete(id, cancellationToken);
        }

        public async Task<Model.SpaceUnit> Activate(int id, CancellationToken cancellationToken)
        {
            var entity = await GetByIdAsync(id, cancellationToken);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            return await state.Activate(id, cancellationToken);
        }

        public async Task<Model.SpaceUnit> Edit(int id, CancellationToken cancellationToken)
        {
            var entity = await GetByIdAsync(id, cancellationToken);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            return await state.Edit(id, cancellationToken);
        }

        public async Task<Model.SpaceUnit> Hide(int id, CancellationToken cancellationToken)
        {
            var entity = await GetByIdAsync(id, cancellationToken);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            return await state.Hide(id, cancellationToken);
        }

        public async Task<Model.SpaceUnit> SetMaintenance(int id, CancellationToken cancellationToken)
        {
            var entity = await GetByIdAsync(id, cancellationToken);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            return await state.SetMaintenance(id, cancellationToken);
        }

        public async Task<Model.SpaceUnit> Restore(int id, CancellationToken cancellationToken)
        {
            var entity = await GetByIdAsync(id, cancellationToken);
            var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
            return await state.Restore(id, cancellationToken);
        }

        public async Task<List<string>> AllowedActions(int id, CancellationToken cancellationToken)
        {
            if (id <= 0)
            {
                var state = BaseSpaceUnitState.CreateState("initial");
                return await state.AllowedActions(null, cancellationToken);
            }
            else
            {
                var entity = await Context.SpaceUnits.FindAsync(id, cancellationToken);
                var state = BaseSpaceUnitState.CreateState(entity.StateMachine);
                return await state.AllowedActions(entity, cancellationToken);
            }
        }

        //public List<Model.DayAvailability> GetAvailabilityForMonth(SpaceUnitSearchObject search)
        //{
        //    if (!search.ByMonth || !search.From.HasValue || !search.To.HasValue)
        //        throw new UserException("Search must have ByMonth = true and From/To dates set.");

        //    var query = AddFilter(search, Context.SpaceUnits.AsQueryable());

        //    var days = new List<DayAvailability>();
        //    for (var day = search.From.Value.Date; day <= search.To.Value.Date; day = day.AddDays(1))
        //    {
        //        int availableCount = 0;

        //        foreach (var su in query)
        //        {
        //            var reservedCount = Context.Reservations
        //                .Where(r => r.SpaceUnitId == su.SpaceUnitId
        //                            && !r.IsDeleted
        //                            && r.StartDate <= day
        //                            && r.EndDate > day)
        //                .Sum(r => r.PeopleCount);

        //            int capacity = su.Capacity;

        //            if (su.WorkspaceTypeId == 1)
        //            {
        //                reservedCount = Context.Reservations
        //                    .Where(r => r.SpaceUnitId == su.SpaceUnitId
        //                                && !r.IsDeleted
        //                                && r.StartDate <= day
        //                                && r.EndDate > day)
        //                    .Sum(r => (int?)r.PeopleCount) ?? 0;
        //                reservedCount += search.PeopleCount ?? 1;
        //            }

        //            if (capacity - reservedCount > 0)
        //                availableCount++;
        //        }

        //        days.Add(new DayAvailability
        //        {
        //            Date = day,
        //            IsAvailable = availableCount > 0,
        //            TotalAvailable = availableCount
        //        });
        //    }

        //    return days;
        //}
    }
}