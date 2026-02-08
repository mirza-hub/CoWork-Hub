using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services;
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
        private readonly IActivityLogService _activityLogService;

        public InitialReservationState(
            _210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService)
            : base(context, mapper, serviceProvider)
        {
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
        }

        public override Model.Reservation Insert(ReservationInsertRequest request)
        {
            var set = Context.Set<Reservation>();

            if (!request.EndDate.HasValue)
                request.EndDate = request.StartDate;

            var numberOfDays = (request.EndDate.Value - request.StartDate).Days + 1;

            if (numberOfDays <= 0)
                throw new UserException("Rezervacija mora biti najmanje 1 dan.");

            if (request.PeopleCount <= 0)
                throw new UserException("Broj ljudi mora biti veći od nule.");

            var spaceUnit = Context.SpaceUnits.FirstOrDefault(s => s.SpaceUnitId == request.SpaceUnitId && !s.IsDeleted);
            if (spaceUnit == null)
                throw new UserException("Prostorna jedinica ne postoji ili je obrisana.");

            if (spaceUnit.WorkspaceTypeId == 1) // Shared/Open Space
            {
                // ukupno ljudi u istom periodu
                var totalPeople = set
                    .Where(r => r.SpaceUnitId == request.SpaceUnitId && !r.IsDeleted && r.StateMachine != "canceled" &&
                                r.StartDate < request.EndDate && r.EndDate > request.StartDate)
                    .Sum(r => r.PeopleCount);

                if (totalPeople + request.PeopleCount > spaceUnit.Capacity)
                    throw new UserException($"Ne može se rezervirati: kapacitet je prekoračen. Max kapacitet je {spaceUnit.Capacity}.");
            }
            else
            {
                // Private/Exclusive spaces → nema preklapanja
                bool overlaps = set.Any(r => r.SpaceUnitId == request.SpaceUnitId && !r.IsDeleted && r.StateMachine != "canceled" &&
                                             r.StartDate < request.EndDate && r.EndDate > request.StartDate);
                if (overlaps)
                    throw new UserException("Ova prostorna jedinica je već zauzeta za odabrani raspon datuma.");

                // provjeri da PeopleCount nije veći od kapaciteta
                if (request.PeopleCount > spaceUnit.Capacity)
                    throw new UserException($"Broj ljudi prekoračuje kapacitet prostorne jedinice ({spaceUnit.Capacity}).");
            }

            var entity = Mapper.Map<Reservation>(request);

            entity.UsersId = (int)_currentUserService.GetUserId();
            entity.StateMachine = "pending";
            entity.CreatedAt = DateTime.UtcNow;
            decimal totalPrice;

            if (spaceUnit.WorkspaceTypeId == 1) // Open space
            {
                totalPrice = request.PeopleCount * spaceUnit.PricePerDay * numberOfDays;
            }
            else
            {
                totalPrice = spaceUnit.PricePerDay * numberOfDays;
            }

            entity.TotalPrice = totalPrice;

            set.Add(entity);
            Context.SaveChanges();

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CREATE",
            "Reservation",
            $"Kreirana rezervacija {entity.ReservationId}");

            return Mapper.Map<Model.Reservation>(entity);
        }

        public override List<string> AllowedActions(Reservation entity)
        {
            return new List<string>() { nameof(Insert) };
        }
    }
}
