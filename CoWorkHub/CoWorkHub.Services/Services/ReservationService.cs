using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.ReservationStateMachine;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class ReservationService : BaseCRUDService<Model.Reservation, ReservationSearchObject, Database.Reservation, ReservationInsertRequest, ReservationUpdateRequest>, IReservationService
    {
        private readonly ICurrentUserService _currentUserService;

        public BaseReservationState BaseReservationState { get; set; }
        public ReservationService(_210095Context context,
            IMapper mapper,
            BaseReservationState baseReservationState,
            ICurrentUserService currentUserService) 
            : base(context, mapper)
        {
            BaseReservationState = baseReservationState;
            _currentUserService = currentUserService;
        }

        public override IQueryable<Reservation> AddFilter(ReservationSearchObject search, IQueryable<Reservation> query)
        {
            query = base.AddFilter(search, query);

            if (search.UserId != null)
                query = query.Where(u => u.UsersId == search.UserId);

            if (!string.IsNullOrWhiteSpace(search?.UserFullName))
            {
                var fullName = search.UserFullName.ToLower().Trim();
                query = query.Where(r =>
                    (r.Users.FirstName + " " + r.Users.LastName).ToLower().Contains(fullName)
                );
            }

            if (!string.IsNullOrWhiteSpace(search?.SpaceUnitName))
                query = query.Where(r => r.SpaceUnit.Name.ToLower().Contains(search.SpaceUnitName.ToLower()));

            if (search.OnlyInactive == true)
            {
                query = query.Where(r =>
                    r.EndDate < DateTime.UtcNow || r.StateMachine == "canceled");
            }

            if (!string.IsNullOrEmpty(search.StateMachine))
                query = query.Where(r => r.StateMachine == search.StateMachine);

            if (search.OnlyActive == true)
            {
                query = query.Where(r => r.EndDate >= DateTime.UtcNow && (r.StateMachine == "pending" || r.StateMachine=="confirmed"));
            }

            if (search!.DateFrom.HasValue)
                query = query.Where(r => r.StartDate >= search.DateFrom.Value);

            if (search.DateTo.HasValue)
                query = query.Where(r => r.EndDate <= search.DateTo.Value);

            if (search.PriceFrom.HasValue)
                query = query.Where(r => r.TotalPrice >= search.PriceFrom.Value);

            if (search.PriceTo.HasValue)
                query = query.Where(r => r.TotalPrice <= search.PriceTo.Value);

            if (search.PeopleFrom.HasValue)
                query = query.Where(r => r.PeopleCount >= search.PeopleFrom.Value);

            if (search.PeopleTo.HasValue)
                query = query.Where(r => r.PeopleCount <= search.PeopleTo.Value);

            if (search.IncludeUser)
                query = query.Include(r => r.Users);

            if (search.IncludeSpaceUnit)
                query = query.Include(r => r.SpaceUnit).ThenInclude(r => r.SpaceUnitImages);

            return query;
        }

        public override Model.Reservation Insert(ReservationInsertRequest request)
        {
            var state = BaseReservationState.CreateState("initial");
            return state.Insert(request);
        }

        public override Model.Reservation Update(int id, ReservationUpdateRequest request)
        {
            var entity = GetById(id);
            var state = BaseReservationState.CreateState(entity.StateMachine);
            return state.Update(id, request);
        }

        public Model.Reservation Confirm(int id)
        {
            var entity = GetById(id);
            var state = BaseReservationState.CreateState(entity.StateMachine);
            return state.Confirm(id);
        }

        public Model.Reservation Cancel(int id)
        {
            var entity = GetById(id);
            var state = BaseReservationState.CreateState(entity.StateMachine);
            return state.Cancel(id);
        }

        public Model.Reservation Complete(int id)
        {
            var entity = GetById(id);
            var state = BaseReservationState.CreateState(entity.StateMachine);
            return state.Complete(id);
        }

        public List<string> AllowedActions(int id)
        {
            if (id <= 0)
            {
                var state = BaseReservationState.CreateState("initial");
                return state.AllowedActions(null);
            }
            else
            {
                var entity = Context.Reservations.Find(id);
                var state = BaseReservationState.CreateState(entity.StateMachine);
                return state.AllowedActions(entity);
            }
        }

        public ActionResult<bool> HasReviewed(int reservationId)
        {
            int userId = (int)_currentUserService.GetUserId();

            bool hasReviewed = Context.Reviews
                .Any(r => r.ReservationId == reservationId
                          && r.Reservation!.UsersId == userId
                          && !r.IsDeleted);

            return hasReviewed;
        }

        public async Task HandleReservationStates()
        {
            var today = DateTime.UtcNow.Date;

            var confirmedReservations = await Context.Reservations
                .Where(r => r.StateMachine == "confirmed" && r.EndDate < today)
                .ToListAsync();

            foreach (var r in confirmedReservations)
            {
                r.StateMachine = "completed";
            }

            // Neplaćene i dan prije starta → Canceled
            var pendingReservations = await Context.Reservations
                .Where(r => r.StateMachine == "pending" &&
                      (r.EndDate < today || r.StartDate.AddDays(-1) <= today))
                .ToListAsync();


            foreach (var r in pendingReservations)
            {
                r.StateMachine = "canceled";
            }

            await Context.SaveChangesAsync();
        }
    }
}
