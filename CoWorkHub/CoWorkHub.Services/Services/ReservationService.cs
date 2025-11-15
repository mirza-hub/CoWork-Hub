using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.ReservationStateMachine;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class ReservationService : BaseCRUDService<Model.Reservation, ReservationSearchObject, Database.Reservation, ReservationInsertRequest, ReservationUpdateRequest>, IReservationService
    {
        public BaseReservationState BaseReservationState { get; set; }
        public ReservationService(_210095Context context, IMapper mapper, BaseReservationState baseReservationState) 
            : base(context, mapper)
        {
            BaseReservationState = baseReservationState;
        }

        public override IQueryable<Reservation> AddFilter(ReservationSearchObject search, IQueryable<Reservation> query)
        {
            query = base.AddFilter(search, query);

            if (search.UserId.HasValue)
                query = query.Where(r => r.UsersId == search.UserId.Value);

            if (search.SpaceUnitId.HasValue)
                query = query.Where(r => r.SpaceUnitId == search.SpaceUnitId.Value);

            if (search.DateFrom.HasValue)
                query = query.Where(r => r.EndDate >= search.DateFrom.Value);

            if (search.DateTo.HasValue)
                query = query.Where(r => r.StartDate <= search.DateTo.Value);

            if (search.PriceFrom.HasValue)
                query = query.Where(r => r.TotalPrice >= search.PriceFrom.Value);

            if (search.PriceTo.HasValue)
                query = query.Where(r => r.TotalPrice <= search.PriceTo.Value);

            if (!string.IsNullOrEmpty(search.StateMachineGTE))
                query = query.Where(r => r.StateMachine.StartsWith(search.StateMachineGTE));

            if (search.IncludeUser)
                query = query.Include(r => r.Users);

            if (search.IncludeSpaceUnit)
                query = query.Include(r => r.SpaceUnit);

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
    }
}
