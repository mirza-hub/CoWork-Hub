using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.ReservationStateMachine
{
    public class InitialReservationState : BaseReservationState
    {
        private readonly ICurrentUserService _currentUserService;

        public InitialReservationState(
            _210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider,
            ICurrentUserService currentUserService)
            : base(context, mapper, serviceProvider)
        {
            _currentUserService = currentUserService;
        }

        public override Model.Reservation Insert(ReservationInsertRequest request)
        {
            var set = Context.Set<Reservation>();

            if (request.StartDate >= request.EndDate)
                throw new UserException("StartDate must be earlier than EndDate.");

            if (request.PeopleCount <= 0)
                throw new UserException("PeopleCount must be greater than zero.");

            var spaceUnit = Context.SpaceUnits.FirstOrDefault(s => s.SpaceUnitId == request.SpaceUnitId && !s.IsDeleted);
            if (spaceUnit == null)
                throw new UserException("Space unit does not exist or is deleted.");

            if (spaceUnit.WorkspaceTypeId == 1) // Shared/Open Space
            {
                // ukupno ljudi u istom periodu
                var totalPeople = set
                    .Where(r => r.SpaceUnitId == request.SpaceUnitId && !r.IsDeleted &&
                                r.StartDate < request.EndDate && r.EndDate > request.StartDate)
                    .Sum(r => r.PeopleCount);

                if (totalPeople + request.PeopleCount > spaceUnit.Capacity)
                    throw new InvalidOperationException($"Cannot reserve: capacity exceeded. Max capacity is {spaceUnit.Capacity}.");
            }
            else
            {
                // Private/Exclusive spaces → nema preklapanja
                bool overlaps = set.Any(r => r.SpaceUnitId == request.SpaceUnitId && !r.IsDeleted &&
                                             r.StartDate < request.EndDate && r.EndDate > request.StartDate);
                if (overlaps)
                    throw new InvalidOperationException("This space unit is already reserved for the selected dates.");

                // provjeri da PeopleCount nije veći od kapaciteta
                if (request.PeopleCount > spaceUnit.Capacity)
                    throw new ArgumentException($"PeopleCount exceeds the capacity of the space unit ({spaceUnit.Capacity}).");
            }

            var entity = Mapper.Map<Reservation>(request);
            entity.UsersId = (int)_currentUserService.GetUserId();
            entity.StateMachine = "pending";
            entity.CreatedAt = DateTime.UtcNow;
            entity.TotalPrice = request.PeopleCount * entity.SpaceUnit.PricePerDay;

            set.Add(entity);
            Context.SaveChanges();

            return Mapper.Map<Model.Reservation>(entity);
        }

        public override List<string> AllowedActions(Reservation entity)
        {
            return new List<string>() { nameof(Insert) };
        }
    }
}
