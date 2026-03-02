using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.ReservationStateMachine
{
    public class ConfirmedReservationState : BaseReservationState
    {
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;
        private readonly INotificationService _notificationService;

        public ConfirmedReservationState(_210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService,
            INotificationService notificationService
            )
            : base(context, mapper, serviceProvider)
        {
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
            _notificationService = notificationService;
        }

        public override Model.Reservation Cancel(int id)
        {
            var reservationSet = Context.Set<Database.Reservation>();
            var paymentSet = Context.Set<Database.Payment>();

            var reservation = reservationSet.Find(id);

            if (reservation == null)
                throw new UserException("Rezervacija nije pronađena.");

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
            var reservationWithSpace = Context.Reservations
                .Include(p => p.SpaceUnit)
                .FirstOrDefault(r => r.ReservationId == reservation.ReservationId);

            if (reservationWithSpace?.SpaceUnit != null)
            {
                _notificationService.Insert(new NotificationInsertRequest
                {
                    UserId = _currentUserId,
                    Message = $"Uspješno ste potvrdili rezervaciju za {reservationWithSpace.SpaceUnit.Name} u periodu {reservation.StartDate:dd.MM.yyyy}-{reservation.EndDate:dd.MM.yyyy} za {reservation.PeopleCount} osoba."
                });
            }
            //_notificationService.Insert(new NotificationInsertRequest
            //{
            //    UserId = _currentUserId,
            //    Message = $"Uspješno ste otkazali rezervaciju za {reservation.SpaceUnit.Name} u periodu {reservation.StartDate.ToString("dd.MM.yyyy")}-{reservation.EndDate.ToString("dd.MM.yyyy")} za {reservation.PeopleCount} osoba."
            //});

            var adminIds = Context.UserRoles
                .Where(ur => ur.Role.RoleName == "Admin")
                .Select(ur => ur.UserId)
                .ToList();

            string _currentUserId2 = "Test";
            User? _currentUser = _currentUserService.GetCurrentUser();
            if (_currentUser != null)
            {
                _currentUserId2 = _currentUser.FirstName + " " + _currentUser.LastName;
            }

            foreach (var adminId in adminIds)
            {
                _notificationService.Insert(new NotificationInsertRequest
                {
                    UserId = adminId,
                    Message = $"{_currentUserId2} je otkazao rezervaciju za {reservation.SpaceUnit.Name} u periodu {reservation.StartDate.ToString("dd.MM.yyyy")}-{reservation.EndDate.ToString("dd.MM.yyyy")} za {reservation.PeopleCount} osoba."
                });
            }

            return Mapper.Map<Model.Reservation>(reservation);
        }

        public override Model.Reservation Complete(int id)
        {
            var set = Context.Set<Database.Reservation>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException("Rezervacija nije pronađena.");
            }

            entity.StateMachine = "completed";

            Context.SaveChanges();

            return Mapper.Map<Model.Reservation>(entity);
        }

        public override List<string> AllowedActions(Reservation entity)
        {
            return new List<string>() { nameof(Cancel), nameof(Complete) };
        }
    }
}
