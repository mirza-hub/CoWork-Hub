using CoWorkHub.Api.Controllers.BaseControllers;
using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WorkingSpaceImageController : BaseCRUDControllerAsync<Model.WorkingSpaceImage, WorkingSpaceImageSearchObject, WorkingSpaceImageInsertRequest, WorkingSpaceImageUpdateRequest>
    {
        private readonly IWorkingSpaceImageService _workingSpaceUnitImageService;

        public WorkingSpaceImageController(IWorkingSpaceImageService service)
            : base(service)
        {
            _workingSpaceUnitImageService = service;
        }

        [Authorize(Roles = "Admin")]
        public override Task<WorkingSpaceImage> Insert(WorkingSpaceImageInsertRequest request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        public override Task<WorkingSpaceImage> Update(int id, WorkingSpaceImageUpdateRequest request, CancellationToken cancellationToken = default)
        {
            return base.Update(id, request, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        public override Task Delete(int id, CancellationToken cancellationToken = default)
        {
            return base.Delete(id, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("uploadBase64")]
        public async Task<ActionResult<List<Model.WorkingSpaceImage>>> UploadBase64([FromBody] WorkingSpaceImageInsertRequest request)
        {
            var result = await _workingSpaceUnitImageService.UploadBase64ImagesAsync(request);
            return Ok(result);
        }

        [AllowAnonymous]
        public override Task<PagedResult<WorkingSpaceImage>> GetList([FromQuery] WorkingSpaceImageSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [AllowAnonymous]
        public override Task<WorkingSpaceImage> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }
    }
}
