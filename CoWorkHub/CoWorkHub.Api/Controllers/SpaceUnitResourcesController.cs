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
    public class SpaceUnitResourcesController : BaseCRUDController<Model.SpaceUnitResources, SpaceUnitResourcesSearchObject, SpaceUnitResourcesInsertRequest, SpaceUnitResourcesUpdateRequest>
    {
        public SpaceUnitResourcesController(ISpaceUnitResourceService service)
            : base(service)
        { }

        [Authorize(Roles = "Admin")]
        public override SpaceUnitResources Insert(SpaceUnitResourcesInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override SpaceUnitResources Update(int id, SpaceUnitResourcesUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [AllowAnonymous]
        public override PagedResult<SpaceUnitResources> GetList([FromQuery] SpaceUnitResourcesSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [AllowAnonymous]
        public override SpaceUnitResources GetById(int id)
        {
            return base.GetById(id);
        }
    }
}
