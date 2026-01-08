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
    public class SpaceUnitImageController : BaseCRUDControllerAsync<Model.SpaceUnitImage, SpaceUnitImageSearchObject, SpaceUnitImageInsertRequest, SpaceUnitImageUpdateRequest>
    {
        private readonly ISpaceUnitImageService _spaceUnitImageService;

        public SpaceUnitImageController(ISpaceUnitImageService service) 
            : base(service)
        {
            _spaceUnitImageService = service;
        }

        [Authorize(Roles = "Admin")]
        public override async Task<SpaceUnitImage> Insert(SpaceUnitImageInsertRequest request, CancellationToken cancellationToken = default)
        {
            return await base.Insert(request, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        public override async Task<SpaceUnitImage> Update(int id, SpaceUnitImageUpdateRequest request, CancellationToken cancellationToken = default)
        {
            return await base.Update(id, request, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        public override async Task Delete(int id, CancellationToken cancellationToken = default)
        {
            await base.Delete(id, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        [HttpPost("uploadBase64")]
        public async Task<ActionResult<List<Model.SpaceUnitImage>>> UploadBase64([FromBody] SpaceUnitImageInsertRequest request)
        {
            var result = await _spaceUnitImageService.UploadBase64ImagesAsync(request);
            return Ok(result);
        }

        [AllowAnonymous]
        public override async Task<PagedResult<SpaceUnitImage>> GetList([FromQuery] SpaceUnitImageSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return await base.GetList(searchObject, cancellationToken);
        }

        [AllowAnonymous]
        public override async Task<SpaceUnitImage> GetById(int id, CancellationToken cancellationToken = default)
        {
            return await base.GetById(id, cancellationToken);
        }
    }
}
