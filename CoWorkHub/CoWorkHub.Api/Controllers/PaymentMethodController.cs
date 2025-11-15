using CoWorkHub.Api.Controllers.BaseControllers;
using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PaymentMethodController : BaseCRUDController<Model.PaymentMethod, PaymentMethodSearchObject, PaymentMethodInsertRequest, PaymentMethodUpdateRequest>
    {
        public PaymentMethodController(IPaymentMethodService service)
            : base(service) { }

        [Authorize(Roles = "Admin")]
        public override PaymentMethod Insert(PaymentMethodInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override PaymentMethod Update(int id, PaymentMethodUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [AllowAnonymous]
        public override PagedResult<PaymentMethod> GetList([FromQuery] PaymentMethodSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [AllowAnonymous]
        public override PaymentMethod GetById(int id)
        {
            return base.GetById(id);
        }
    }
}
