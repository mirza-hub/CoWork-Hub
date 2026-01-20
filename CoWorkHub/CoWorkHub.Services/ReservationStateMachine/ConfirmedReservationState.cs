using CoWorkHub.Model.Exceptions;
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
