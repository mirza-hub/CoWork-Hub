using CoWorkHub.Api.Controllers.BaseControllers;
using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.WorkingSpaceStateMachine;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WorkingSpaceController : BaseCRUDController<Model.WorkingSpace, WorkingSpaceSearchObject, WorkingSpaceInsertRequest, WorkingSpaceUpdateRequest>
    {
        public WorkingSpaceController(IWorkingSpaceService service)
            : base(service) { }

        [HttpPut("{id}/activate")]
        public WorkingSpace Activate(int id)
        {
            return (_service as IWorkingSpaceService).Activate(id);
        }

        [HttpPut("{id}/edit")]
        public Model.WorkingSpace Edit(int id)
        {
            return (_service as IWorkingSpaceService).Edit(id);
        }

        [HttpPut("{id}/hide")]
        public Model.WorkingSpace Hide(int id)
        {
            return (_service as IWorkingSpaceService).Hide(id);
        }

        [HttpPut("{id}/setMaintenance")]
        public Model.WorkingSpace SetMaintenance(int id)
        {
            return (_service as IWorkingSpaceService).SetMaintenance(id);
        }

        [HttpPut("{id}/restore")]
        public Model.WorkingSpace Restore(int id)
        {
            return (_service as IWorkingSpaceService).Restore(id);
        }

        [HttpGet("{id}/allowedActions")]
        public List<string> AllowedActions(int id)
        {
            return (_service as IWorkingSpaceService).AllowedActions(id);
        }
    }
}
