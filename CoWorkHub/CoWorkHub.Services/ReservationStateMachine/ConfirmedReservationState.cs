using CoWorkHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.ReservationStateMachine
{
    public class ConfirmedReservationState : BaseReservationState
    {

        public ConfirmedReservationState(_210095Context context, IMapper mapper, IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        { }

        public override Model.Reservation Cancel(int id)
        {
            var set = Context.Set<Database.Reservation>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new Exception("Reservation not found.");
            }

            entity.StateMachine = "canceled";
            entity.CanceledAt = DateTime.UtcNow;

            Context.SaveChanges();

            return Mapper.Map<Model.Reservation>(entity);
        }

        public override Model.Reservation Complete(int id)
        {
            var set = Context.Set<Database.Reservation>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new Exception("Reservation not found.");
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
