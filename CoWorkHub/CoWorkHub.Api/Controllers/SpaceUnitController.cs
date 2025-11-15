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
    public class SpaceUnitController : BaseCRUDController<Model.SpaceUnit, SpaceUnitSearchObject, SpaceUnitInsertRequest, SpaceUnitUpdateRequest>
    {
        public SpaceUnitController(ISpaceUnitService service)
            : base(service) { }

        [Authorize(Roles = "Admin")]
        public override SpaceUnit Insert(SpaceUnitInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override SpaceUnit Update(int id, SpaceUnitUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [AllowAnonymous]
        public override PagedResult<SpaceUnit> GetList([FromQuery] SpaceUnitSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [AllowAnonymous]
        public override SpaceUnit GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/activate")]
        public SpaceUnit Activate(int id)
        {
            return (_service as ISpaceUnitService).Activate(id);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/edit")]
        public Model.SpaceUnit Edit(int id)
        {
            return (_service as ISpaceUnitService).Edit(id);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/hide")]
        public Model.SpaceUnit Hide(int id)
        {
            return (_service as ISpaceUnitService).Hide(id);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/setMaintenance")]
        public Model.SpaceUnit SetMaintenance(int id)
        {
            return (_service as ISpaceUnitService).SetMaintenance(id);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/restore")]
        public Model.SpaceUnit Restore(int id)
        {
            return (_service as ISpaceUnitService).Restore(id);
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("{id}/allowedActions")]
        public List<string> AllowedActions(int id)
        {
            return (_service as ISpaceUnitService).AllowedActions(id);
        }
    }
}
