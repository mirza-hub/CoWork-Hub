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
    public class SpaceUnitController : BaseCRUDControllerAsync<Model.SpaceUnit, SpaceUnitSearchObject, SpaceUnitInsertRequest, SpaceUnitUpdateRequest>
    {
        public SpaceUnitController(ISpaceUnitService service)
            : base(service) { }

        [Authorize(Roles = "Admin")]
        public override async Task<SpaceUnit> Insert(SpaceUnitInsertRequest request, CancellationToken cancellationToken = default)
        {
            return await base.Insert(request, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<SpaceUnit> Update(int id, SpaceUnitUpdateRequest request, CancellationToken cancellationToken = default)
        {
            return await base.Update(id, request, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        public override async Task Delete(int id, CancellationToken cancellationToken = default)
        {
            await base.Delete(id, cancellationToken);
        }

        [AllowAnonymous]
        public override async Task<PagedResult<SpaceUnit>> GetList([FromQuery] SpaceUnitSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return await base.GetList(searchObject, cancellationToken);
        }

        [AllowAnonymous]
        public override async Task<SpaceUnit> GetById(int id, CancellationToken cancellationToken = default)
        {
            return await base.GetById(id, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/activate")]
        public async Task<SpaceUnit> Activate(int id, CancellationToken cancellationToken)
        {
            return await (_service as ISpaceUnitService).Activate(id, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/edit")]
        public async Task<SpaceUnit> Edit(int id, CancellationToken cancellationToken)
        {
            return await(_service as ISpaceUnitService).Edit(id, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/hide")]
        public async Task<SpaceUnit> Hide(int id, CancellationToken cancellationToken)
        {
            return await(_service as ISpaceUnitService).Hide(id, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/setMaintenance")]
        public async Task<SpaceUnit> SetMaintenance(int id, CancellationToken cancellationToken)
        {
            return await (_service as ISpaceUnitService).SetMaintenance(id, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/restore")]
        public async Task<SpaceUnit> Restore(int id, CancellationToken cancellationToken)
        {
            return await (_service as ISpaceUnitService).Restore(id, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        [HttpGet("{id}/allowedActions")]
        public async Task<List<string>> AllowedActions(int id, CancellationToken cancellationToken)
        {
            return await (_service as ISpaceUnitService).AllowedActions(id, cancellationToken);
        }

        [AllowAnonymous]
        [HttpPost("{id}/availability")]
        public async Task<List<DayAvailability>> GetAvailability(int id, [FromBody] SpaceUnitAvailabilityRequest request, CancellationToken cancellationToken)
        {
            return await (_service as ISpaceUnitService).GetAvailability(id, request.From, request.To, request.PeopleCount);
        }


        //[AllowAnonymous]
        //[HttpGet("availability")]
        //public List<DayAvailability> GetAvailabilityForMonth([FromQuery] SpaceUnitSearchObject search)
        //{
        //    return (_service as ISpaceUnitService).GetAvailabilityForMonth(search);
        //}

    }
}
