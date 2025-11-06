using CoWorkHub.Api.Controllers.BaseControllers;
using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ResourcesController : BaseCRUDController<Resource, ResourcesSearchObject, ResourcesInsertRequest, ResourcesUpdateRequest>
    {
        public ResourcesController(IResourcesService service)
            : base(service) {  }
    }
}
