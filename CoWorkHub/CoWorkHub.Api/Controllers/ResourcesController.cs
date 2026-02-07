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
    public class ResourcesController : BaseCRUDController<Resource, ResourcesSearchObject, ResourcesInsertRequest, ResourcesUpdateRequest>
    {
        public ResourcesController(IResourcesService service)
            : base(service) {  }

        [Authorize(Roles = "Admin")]
        public override Resource Insert(ResourcesInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override Resource Update(int id, ResourcesUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [AllowAnonymous]
        public override PagedResult<Resource> GetList([FromQuery] ResourcesSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [AllowAnonymous]
        public override Resource GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/restore")]
        public Resource RestoreUser(int id)
        {
            return (_service as IResourcesService).RestoreResource(id);
        }
    }
}
