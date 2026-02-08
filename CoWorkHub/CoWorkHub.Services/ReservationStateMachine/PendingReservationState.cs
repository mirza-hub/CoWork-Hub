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
    public class PendingReservationState : BaseReservationState
    {
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;

        public PendingReservationState(_210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider,
            IActivityLogService activityLogService,
            ICurrentUserService currentUserService)
            : base(context, mapper, serviceProvider)
        { 
            _activityLogService = activityLogService;
            _currentUserService = currentUserService;
        }

        public override Model.Reservation Update(int id, ReservationUpdateRequest request)
        {
            var set = Context.Set<Database.Reservation>();

            var entity = set.Find(id);

            if (entity == null)
                throw new UserException("Rezervacija nije pronađena.");

            if (entity.IsDeleted)
                throw new UserException("Nije moguće ažurirati obrisanu rezervaciju.");

            if (request.StartDate.HasValue && request.StartDate.Value < DateTime.UtcNow)
                throw new UserException("Početni datum ne može biti u prošlosti.");

            if (request.EndDate.HasValue && request.EndDate.Value < DateTime.UtcNow)
                throw new Exception("Krajnji datum ne može biti u prošlosti.");

            var startDate = request.StartDate ?? entity.StartDate;
            var endDate = request.EndDate ?? entity.EndDate;

            bool conflictExists = set.Any(r =>
                r.SpaceUnitId == entity.SpaceUnitId &&
                r.ReservationId != id && 
                r.IsDeleted == false &&
                (
                    (startDate >= r.StartDate && startDate < r.EndDate) ||
                    (endDate > r.StartDate && endDate <= r.EndDate) ||
                    (startDate <= r.StartDate && endDate >= r.EndDate)
                )
            );

            if (conflictExists)
                throw new UserException("Rezervacijski konflikt sa postojećom rezervacijom za ovaj prostor.");

            Mapper.Map(request, entity);
            entity.TotalPrice = (decimal)request.PeopleCount * entity.SpaceUnit.PricePerDay;

            Context.SaveChanges();

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "UPDATE",
            "Reservation",
            $"Ažurirana rezervacija {entity.ReservationId}");

            return Mapper.Map<Model.Reservation>(entity);
        }

        public override Model.Reservation Confirm(int id)
        {
            var set = Context.Set<Database.Reservation>();

            var entity = set.Find(id);

            entity.StateMachine = "confirmed";

            Context.SaveChanges();

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CONFIRM",
            "Reservation",
            $"Potvrđena rezervacija {entity.ReservationId}");

            return Mapper.Map<Model.Reservation>(entity);
        }

        public override Model.Reservation Cancel(int id)
        {
            var reservationSet = Context.Set<Database.Reservation>();
            var paymentSet = Context.Set<Database.Payment>();

            var reservation = reservationSet.Find(id);

            if (reservation == null)
                throw new UserException("Rezervacija nije pronađeno.");

            var today = DateTime.UtcNow.Date;
            var startDate = reservation.StartDate.Date;

            var daysUntilStart = (startDate - today).TotalDays;

            if (daysUntilStart < 3)
                throw new UserException("Rezervacija se ne može otkazati manje od 3 dana prije početka.");

            reservation.StateMachine = "canceled";
            reservation.CanceledAt = DateTime.UtcNow;

            var payment = paymentSet.FirstOrDefault(p => p.ReservationId == id);

            if (payment != null)
            {
                payment.StateMachine = "refunded";
            }

            Context.SaveChanges();

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CANCEL",
            "Reservation",
            $"Otkazana rezervacija {id}");

            return Mapper.Map<Model.Reservation>(reservation);
        }

        public override List<string> AllowedActions(Reservation entity)
        {
            return new List<string>() { nameof(Update), nameof(Confirm), nameof(Cancel) };
        }
    }
}
