using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
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
        public PaymentMethodService(_210095Context context, IMapper mapper) 
            : base(context, mapper)
        { }

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
                    throw new UserException("A payment method with this name already exists in the database.");
            }
        }

        public override void BeforeUpdate(PaymentMethodUpdateRequest request, PaymentMethod entity)
        {
            base.BeforeUpdate(request, entity);

            var existingPaymentMethod = Context.PaymentMethods
                .FirstOrDefault(x => x.PaymentMethodName.ToLower() == request.PaymentMethodName.ToLower());

            if (existingPaymentMethod != null)
            {
                throw new UserException("Another payment method with this name already exists in the database.");
            }
        }
    }
}
