using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CityController : BaseController<Model.City, CitySearchObject>
    {
        public CityController(ICityInterface service)
            : base(service) { }
    }
}
