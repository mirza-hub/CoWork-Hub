using CoWorkHub.Model;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin")]
    public class ActivityLogController
    {
        protected IActivityLogService _service;
        public ActivityLogController(IActivityLogService service) 
        { 
            _service = service;
        }

        [HttpGet]
        public virtual PagedResult<Model.ActivityLog> GetList([FromQuery] ActivityLogSearchObject searchObject)
        {
            return _service.GetPaged(searchObject);
        }
    }
}
