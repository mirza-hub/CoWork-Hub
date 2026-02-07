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
                                    r.StartDate <= to &&
                                    r.EndDate >= from
                                )
                                .Sum(r => (int?)r.PeopleCount) ?? 0
                            ) + requestedPeopleCount <= su.Capacity
                        )
                        : !Context.Reservations.Any(r =>
                            r.SpaceUnitId == su.SpaceUnitId &&
                            !r.IsDeleted &&
                            (r.StateMachine == "pending" || r.StateMachine == "confirmed") &&
                            r.StartDate <= to &&
                            r.EndDate >= from
                        ) &&
                        su.Capacity >= requestedPeopleCount
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

        public async Task<List<DayAvailability>> GetAvailability(int spaceUnitId, DateTime from, DateTime to, int peopleCount)
        {
            var spaceUnit = await Context.SpaceUnits.AsNoTracking().FirstOrDefaultAsync(x => 
            x.SpaceUnitId == spaceUnitId &&
            !x.IsDeleted &&
            x.StateMachine == "active");

            if (from > to)
                throw new UserException("Neispravan raspon datuma.");

            if (peopleCount <= 0)
                throw new UserException("PeopleCount mora biti veći od 0.");

            if (spaceUnit == null)
                throw new UserException("Space unit ne postoji.");

            var reservations = await Context.Reservations
                .Where(r =>
                r.SpaceUnitId == spaceUnitId &&
                !r.IsDeleted &&
                (r.StateMachine == "pending" || r.StateMachine == "confirmed" || r.StateMachine == "completed") &&
                r.EndDate > from).ToListAsync();


            var result = new List<DayAvailability>();

            for (var day = from.Date; day <= to.Date; day = day.AddDays(1))
            {
                var dayReservations = reservations
                    .Where(r => r.StartDate.Date <= day && r.EndDate.Date >= day)
                    .ToList();

                bool isAvailable;

                if (spaceUnit.WorkspaceTypeId == 1) // open space
                {
                    var reserved = dayReservations.Sum(r => r.PeopleCount);
                    isAvailable = reserved + peopleCount <= spaceUnit.Capacity;
                }
                else // private office / event hall
                {
                    isAvailable = !dayReservations.Any() && peopleCount <= spaceUnit.Capacity;
                }

                result.Add(new DayAvailability
                {
                    Date = day,
                    IsAvailable = isAvailable,
                    Capacity = spaceUnit.Capacity,
                    Reserved = spaceUnit.WorkspaceTypeId == 1
                                ? dayReservations.Sum(r => r.PeopleCount)
                                : dayReservations.Any() ? spaceUnit.Capacity : 0,
                    Free = spaceUnit.Capacity - (spaceUnit.WorkspaceTypeId == 1
                                ? dayReservations.Sum(r => r.PeopleCount)
                                : dayReservations.Any() ? spaceUnit.Capacity : 0)
                });
            }

            return result;
        }
    }
}