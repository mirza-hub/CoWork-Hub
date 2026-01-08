using CoWorkHub.Api.Controllers.BaseControllers;
using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class PaymentController : BaseCRUDController<Model.Payment, PaymentSearchObject, PaymentInsertRequest, PaymentUpdateRequest>
    {
        public PaymentController(IPaymentService service) 
            : base(service)
        { }

        [Authorize]
        public override Payment Insert(PaymentInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize]
        public override Payment Update(int id, PaymentUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [Authorize]
        public override PagedResult<Payment> GetList([FromQuery] PaymentSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize]
        public override Payment GetById(int id)
        {
            return base.GetById(id);
        }
    }
}
