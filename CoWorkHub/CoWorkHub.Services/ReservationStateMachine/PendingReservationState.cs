using CoWorkHub.Model;
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
    public class PendingReservationState : BaseReservationState
    {
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;
        private readonly INotificationService _notificationService;

        public PendingReservationState(_210095Context context, 
            IMapper mapper,
            IServiceProvider serviceProvider,
            IActivityLogService activityLogService,
            ICurrentUserService currentUserService
,
            INotificationService notificationService
            )
            : base(context, mapper, serviceProvider)
        {
            _activityLogService = activityLogService;
            _currentUserService = currentUserService;
            _notificationService = notificationService;
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
            _notificationService.Insert(new NotificationInsertRequest
            {
                UserId = _currentUserId,
                Message = $"Uspješno ste ažurirali rezervaciju za {entity.SpaceUnit.Name} u periodu {entity.StartDate.ToString("dd.MM.yyyy")}-{entity.EndDate.ToString("dd.MM.yyyy")} za {entity.PeopleCount} osoba."
            });

            var adminIds = Context.UserRoles
                .Where(ur => ur.Role.RoleName == "Admin")
                .Select(ur => ur.UserId)
                .ToList();

            string _currentUserId2 = "Test";
            Database.User? _currentUser = _currentUserService.GetCurrentUser();
            if (_currentUser != null)
            {
                _currentUserId2 = _currentUser.FirstName + " " + _currentUser.LastName;
            }

            foreach (var adminId in adminIds)
            {
                _notificationService.Insert(new NotificationInsertRequest
                {
                    UserId = adminId,
                    Message = $"{_currentUserId2} je ažurirao rezervaciju za {entity.SpaceUnit.Name} u periodu {entity.StartDate.ToString("dd.MM.yyyy")}-{entity.EndDate.ToString("dd.MM.yyyy")} za {entity.PeopleCount} osoba."
                });
            }

            return Mapper.Map<Model.Reservation>(entity);
        }

        public override Model.Reservation Confirm(int id)
        {
            var set = Context.Set<Database.Reservation>()
                .Include(r => r.SpaceUnit)
                .FirstOrDefault(r => r.ReservationId == id); ;

            //var entity = set.Find(id);

            //entity.StateMachine = "confirmed";
            set.StateMachine = "confirmed";

            Context.SaveChanges();

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CONFIRM",
            "Reservation",
            $"Potvrđena rezervacija {set.ReservationId}");

            //var reservationWithSpace = Context.Reservations
            //    .Include(p => p.SpaceUnit)
            //    .FirstOrDefault(r => r.ReservationId == entity.ReservationId);

            //if (reservationWithSpace?.SpaceUnit != null)
            //{
            //    _notificationService.Insert(new NotificationInsertRequest
            //    {
            //        UserId = _currentUserId,
            //        Message = $"Uspješno ste potvrdili rezervaciju za {reservationWithSpace.SpaceUnit.Name} u periodu {entity.StartDate:dd.MM.yyyy}-{entity.EndDate:dd.MM.yyyy} za {entity.PeopleCount} osoba."
            //    });
            //}
            _notificationService.Insert(new NotificationInsertRequest
            {
                UserId = _currentUserId,
                Message = $"Uspješno ste potvrdili rezervaciju za {set.SpaceUnit.Name} u periodu {set.StartDate.ToString("dd.MM.yyyy")}-{set.EndDate.ToString("dd.MM.yyyy")} za {set.PeopleCount} osoba."
            });

            var adminIds = Context.UserRoles
                .Where(ur => ur.Role.RoleName == "Admin")
                .Select(ur => ur.UserId)
                .ToList();

            string _currentUserId2 = "Test";
            Database.User? _currentUser = _currentUserService.GetCurrentUser();
            if (_currentUser != null)
            {
                _currentUserId2 = _currentUser.FirstName + " " + _currentUser.LastName;
            }

            foreach (var adminId in adminIds)
            {
                _notificationService.Insert(new NotificationInsertRequest
                {
                    UserId = adminId,
                    Message = $"{_currentUserId2} je potvrdio rezervaciju za {set.SpaceUnit.Name} u periodu {set.StartDate.ToString("dd.MM.yyyy")}-{set.EndDate.ToString("dd.MM.yyyy")} za {set.PeopleCount} osoba."
                });
            }

            return Mapper.Map<Model.Reservation>(set);
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
            _notificationService.Insert(new NotificationInsertRequest
            {
                UserId = _currentUserId,
                Message = $"Uspješno ste otkazali rezervaciju za {reservation.SpaceUnit.Name} u periodu {reservation.StartDate.ToString("dd.MM.yyyy")}-{reservation.EndDate.ToString("dd.MM.yyyy")} za {reservation.PeopleCount} osoba."
            });

            var adminIds = Context.UserRoles
                .Where(ur => ur.Role.RoleName == "Admin")
                .Select(ur => ur.UserId)
                .ToList();

            string _currentUserId2 = "Test";
            Database.User? _currentUser = _currentUserService.GetCurrentUser();
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

        public override List<string> AllowedActions(Database.Reservation entity)
        {
            return new List<string>() { nameof(Update), nameof(Confirm), nameof(Cancel) };
        }
    }
}
