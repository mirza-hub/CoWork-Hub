using CoWorkHub.Api.Controllers.BaseControllers;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CityController : BaseCRUDController<Model.City, CitySearchObject, CityInsertRequest, CityUpdateRequest>
    {
        public CityController(ICityService service)
            : base(service) { }
    }
}
