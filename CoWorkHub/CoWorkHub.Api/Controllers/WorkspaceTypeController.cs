using CoWorkHub.Api.Controllers.BaseControllers;
using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WorkspaceTypeController : BaseCRUDController<Model.WorkspaceType, WorkspaceTypeSearchObject, WorkspaceTypeInsertRequest, WorkspaceTypeUpdateRequest>
    {
        public WorkspaceTypeController(IWorkspaceTypeService service) 
            : base(service) { }

        [Authorize(Roles = "Admin")]
        public override WorkspaceType Insert(WorkspaceTypeInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin")]
        public override WorkspaceType Update(int id, WorkspaceTypeUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [AllowAnonymous]
        public override PagedResult<WorkspaceType> GetList([FromQuery] WorkspaceTypeSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [AllowAnonymous]
        public override WorkspaceType GetById(int id)
        {
            return base.GetById(id);
        }
    }
}
