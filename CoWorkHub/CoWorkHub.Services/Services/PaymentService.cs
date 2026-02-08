using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class PaymentService : BaseCRUDService<Model.Payment, PaymentSearchObject, Database.Payment, PaymentInsertRequest, PaymentUpdateRequest>, IPaymentService
    {
        private readonly IReservationService _reservationService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;

        public PaymentService(_210095Context context, IMapper mapper, 
            IReservationService reservationService,
            IActivityLogService activityLogService,
            ICurrentUserService currentUserService)
            : base(context, mapper) 
        {
            _reservationService = reservationService;
            _activityLogService = activityLogService;
            _currentUserService = currentUserService;
        }

        public override IQueryable<Payment> AddFilter(PaymentSearchObject search, IQueryable<Payment> query)
        {
            query = base.AddFilter(search, query);

            if (search.PaymentId.HasValue)
                query = query.Where(x => x.PaymentId == search.PaymentId);

            if (search.ReservationId.HasValue)
                query = query.Where(x => x.ReservationId == search.ReservationId);

            if (search.PaymentMethodId.HasValue)
                query = query.Where(x => x.PaymentMethodId == search.PaymentMethodId);

            if (!string.IsNullOrWhiteSpace(search.StateMachine))
                query = query.Where(x => x.StateMachine == search.StateMachine);

            if (search.DateFrom.HasValue)
                query = query.Where(x => x.PaymentDate >= search.DateFrom);

            if (search.DateTo.HasValue)
                query = query.Where(x => x.PaymentDate <= search.DateTo);

            if (search.PriceFrom.HasValue)
                query = query.Where(x => x.TotalPaymentAmount >= search.PriceFrom);

            if (search.PriceTo.HasValue)
                query = query.Where(x => x.TotalPaymentAmount <= search.PriceTo);

            return query;
        }

        public override void BeforeInsert(PaymentInsertRequest request, Payment entity)
        {
            base.BeforeInsert(request, entity);

            var reservation = Context.Reservations.Find(request.ReservationId);
            if (reservation == null)
                throw new UserException("Rezervacija ne postoji.");

            entity.PaymentDate = DateTime.UtcNow;
            entity.CreatedAt = DateTime.UtcNow;
            entity.StateMachine = "paid";
        }

        public override void AfterInsert(PaymentInsertRequest request, Payment entity)
        {
            base.AfterInsert(request, entity);

            var reservation = Context.Reservations.Find(request.ReservationId);
            if (reservation == null)
                throw new UserException("Rezervacija ne postoji.");

            _reservationService.Confirm(reservation.ReservationId);

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CREATE",
            "Payment",
            $"Kreirano plaćanje {entity.PaymentId}");
        }

        public override void BeforeUpdate(PaymentUpdateRequest request, Payment entity)
        {
            base.BeforeUpdate(request, entity);

            entity.ModifiedAt = DateTime.UtcNow;

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "UPDATE",
            "Payment",
            $"Ažurirano plaćanje {entity.PaymentId}");
        }

        public override void AfterDelete(Payment entity)
        {
            base.AfterDelete(entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "DELETE",
            "Payment",
            $"Obrisano plaćanje {entity.PaymentId}");
        }
    }
}
