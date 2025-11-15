using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Services.Database;
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
        public PendingReservationState(_210095Context context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        { }

        public override Model.Reservation Update(int id, ReservationUpdateRequest request)
        {
            var set = Context.Set<Database.Reservation>();

            var entity = set.Find(id);

            if (entity == null)
                throw new UserException("Reservation not found.");

            if (entity.IsDeleted)
                throw new UserException("Cannot update a deleted reservation.");

            if (request.StartDate.HasValue && request.StartDate.Value < DateTime.UtcNow)
                throw new UserException("Start date cannot be in the past.");

            if (request.EndDate.HasValue && request.EndDate.Value < DateTime.UtcNow)
                throw new Exception("End date cannot be in the past.");

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
                throw new Exception("The reservation conflicts with an existing reservation for this space.");

            Mapper.Map(request, entity);
            entity.TotalPrice = (decimal)request.PeopleCount * entity.SpaceUnit.PricePerDay;

            Context.SaveChanges();

            return Mapper.Map<Model.Reservation>(entity);
        }

        public override Model.Reservation Confirm(int id)
        {
            var set = Context.Set<Database.Reservation>();

            var entity = set.Find(id);

            entity.StateMachine = "confirmed";

            Context.SaveChanges();

            return Mapper.Map<Model.Reservation>(entity);
        }

        public override List<string> AllowedActions(Reservation entity)
        {
            return new List<string>() { nameof(Update), nameof(Confirm) };
        }
    }
}
