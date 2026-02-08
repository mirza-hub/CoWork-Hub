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
    public class PaymentMethodService : BaseCRUDService<Model.PaymentMethod, PaymentMethodSearchObject, Database.PaymentMethod, PaymentMethodInsertRequest, PaymentMethodUpdateRequest>, IPaymentMethodService
    {
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;

        public PaymentMethodService(_210095Context context, 
            IMapper mapper,
            IActivityLogService activityLogService,
            ICurrentUserService currentUserService
            ) 
            : base(context, mapper)
        {
            _activityLogService = activityLogService;
            _currentUserService = currentUserService;
        }

        public override IQueryable<PaymentMethod> AddFilter(PaymentMethodSearchObject search, IQueryable<PaymentMethod> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.PaymentMethodNameGTE))
            {
                query = query.Where(x => x.PaymentMethodName.ToLower().StartsWith(search.PaymentMethodNameGTE.ToLower()));
            }

            return query;
        }

        public override void BeforeInsert(PaymentMethodInsertRequest request, PaymentMethod entity)
        {
            base.BeforeInsert(request, entity);

            var existingPaymentMethod = Context.PaymentMethods
                .FirstOrDefault(x => x.PaymentMethodName.ToLower() == request.PaymentMethodName.ToLower());

            if (existingPaymentMethod != null)
            {
                if (existingPaymentMethod.PaymentMethodName.Equals(request.PaymentMethodName, StringComparison.OrdinalIgnoreCase))
                    throw new UserException("Način plaćanja sa ovim imenom već postoji u bazi.");
            }
        }

        public override void BeforeUpdate(PaymentMethodUpdateRequest request, PaymentMethod entity)
        {
            base.BeforeUpdate(request, entity);

            var existingPaymentMethod = Context.PaymentMethods
                .FirstOrDefault(x => x.PaymentMethodName.ToLower() == request.PaymentMethodName.ToLower());

            if (existingPaymentMethod != null)
            {
                throw new UserException("Način plaćanja sa ovim imenom već postoji u bazi.");
            }
        }

        public Model.PaymentMethod RestorePaymentMethod(int id)
        {
            var set = Context.Set<Database.PaymentMethod>();

            var entity = set.Find(id);

            if (entity == null)
                throw new UserException("Metoda plaćanja nije pronađena.");

            if (entity.IsDeleted == false)
                throw new UserException("Metodu plaćanja nije moguće vratiti jer nije obrisana.");

            entity.IsDeleted = false;
            entity.DeletedAt = null;

            Context.SaveChanges();

            return Mapper.Map<Model.PaymentMethod>(entity);
        }

        public override void AfterInsert(PaymentMethodInsertRequest request, PaymentMethod entity)
        {
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CREATE",
            "PaymentMethod",
            $"Kreiran novi način plaćanja {entity.PaymentMethodId}");
        }

        public override void AfterUpdate(PaymentMethodUpdateRequest request, PaymentMethod entity)
        {
            base.AfterUpdate(request, entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "UPDATE",
            "PaymentMethod",
            $"Ažuriran način plaćanja {entity.PaymentMethodId}");
        }

        public override void AfterDelete(PaymentMethod entity)
        {
            base.AfterDelete(entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "DELETE",
            "PaymentMethod",
            $"Obrisan način plaćanja {entity.PaymentMethodId}");
        }
    }
}
