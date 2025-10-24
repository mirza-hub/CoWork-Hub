using CoWorkHub.Model;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CountryController : BaseController<Model.Country, CountrySearchObject>
    {
        public CountryController(ICountryService service)
        : base(service) { }
    }
}
