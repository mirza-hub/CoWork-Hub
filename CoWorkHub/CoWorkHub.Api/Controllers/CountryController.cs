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
    public class CountryController : BaseCRUDController<Model.Country, CountrySearchObject, CountryInsertRequest, CountryUpdateRequest>
    {
        public CountryController(ICountryService service)
        : base(service) { }

        [Authorize(Roles = "Admin")]
        public override Country Insert(CountryInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override Country Update(int id, CountryUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [AllowAnonymous]
        public override PagedResult<Country> GetList([FromQuery] CountrySearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [AllowAnonymous]
        public override Country GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/restore")]
        public Country RestoreCountry(int id)
        {
            return (_service as ICountryService).RestoreCountry(id);
        }
    }
}
