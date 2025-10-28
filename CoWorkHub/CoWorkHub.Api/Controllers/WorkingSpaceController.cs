using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WorkingSpaceController : BaseCRUDController<Model.WorkingSpace, WorkingSpaceSearchObject, WorkingSpaceInsertRequest, WorkingSpaceUpdateRequest>
    {
        public WorkingSpaceController(IWorkingSpaceService service) 
            : base(service) { }
    }
}
