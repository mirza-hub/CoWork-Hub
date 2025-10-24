using CoWorkHub.Model;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ResourcesController : BaseController<Model.Resource, ResourcesSearchObject>
    {
        public ResourcesController(IResourcesService service)
            : base(service) {  }
    }
}
