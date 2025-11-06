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
    public class CountryController : BaseCRUDController<Model.Country, CountrySearchObject, CountryInsertRequest, CountryUpdateRequest>
    {
        public CountryController(ICountryService service)
        : base(service) { }
    }
}
