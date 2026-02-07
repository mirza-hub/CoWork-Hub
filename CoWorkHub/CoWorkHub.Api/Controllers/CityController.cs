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
    public class CityController : BaseCRUDController<Model.City, CitySearchObject, CityInsertRequest, CityUpdateRequest>
    {
        public CityController(ICityService service)
            : base(service) { }

        [Authorize(Roles = "Admin")]
        public override City Insert(CityInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override City Update(int id, CityUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [AllowAnonymous]
        public override PagedResult<City> GetList([FromQuery] CitySearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [AllowAnonymous]
        public override City GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/restore")]
        public City RestoreCity(int id)
        {
            return (_service as ICityService).RestoreCity(id);
        }
    }
}
