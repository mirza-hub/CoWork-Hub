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
    public class ReservationController : BaseCRUDController<Model.Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>
    {
        public ReservationController(IReservationService service) 
            : base(service) { }

        [Authorize(Roles = "Admin,User")]
        public override Reservation Insert(ReservationInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin,User")]
        public override Reservation Update(int id, ReservationUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin,User")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [Authorize(Roles = "Admin,User")]
        public override PagedResult<Reservation> GetList([FromQuery] ReservationSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin,User")]
        public override Reservation GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin,User")]
        [HttpPut("{id}/confirm")]
        public Model.Reservation Confirm(int id)
        {
            return (_service as IReservationService).Confirm(id);
        }

        [Authorize(Roles = "Admin,User")]
        [HttpPut("{id}/cancel")]
        public Model.Reservation Cancel(int id)
        {
            return (_service as IReservationService).Cancel(id);
        }

        [Authorize(Roles = "Admin,User")]
        [HttpPut("{id}/complete")]
        public Model.Reservation Complete(int id)
        {
            return (_service as IReservationService).Complete(id);
        }

        [Authorize(Roles = "Admin,User")]
        [HttpPut("{id}/allowedActions")]
        public List<string> AllowedActions(int id)
        {
            return (_service as IReservationService).AllowedActions(id);
        }
    }
}
