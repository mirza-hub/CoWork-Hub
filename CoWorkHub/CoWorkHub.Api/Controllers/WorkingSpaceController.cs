using CoWorkHub.Api.Controllers.BaseControllers;
using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.WorkingSpaceStateMachine;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WorkingSpaceController : BaseCRUDController<Model.WorkingSpace, WorkingSpaceSearchObject, WorkingSpaceInsertRequest, WorkingSpaceUpdateRequest>
    {
        public WorkingSpaceController(IWorkingSpaceService service)
            : base(service) { }

        
        [Authorize(Roles = "Admin")]
        public override WorkingSpace Insert(WorkingSpaceInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override WorkingSpace Update(int id, WorkingSpaceUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [AllowAnonymous]
        public override PagedResult<WorkingSpace> GetList([FromQuery] WorkingSpaceSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [AllowAnonymous]
        public override WorkingSpace GetById(int id)
        {
            return base.GetById(id);
        }
    }
}
