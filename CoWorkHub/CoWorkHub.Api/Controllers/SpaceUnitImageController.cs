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
    public class SpaceUnitImageController : BaseCRUDControllerAsync<Model.SpaceUnitImage, SpaceUnitImageSearchObject, SpaceUnitImageInsert, SpaceUnitImageUpdate>
    {
        private readonly ISpaceUnitImageService _spaceUnitImageService;

        public SpaceUnitImageController(ISpaceUnitImageService service) 
            : base(service)
        {
            _spaceUnitImageService = service;
        }

        [Authorize(Roles = "Admin")]
        public override Task<SpaceUnitImage> Insert(SpaceUnitImageInsert request, CancellationToken cancellationToken = default)
        {
            return base.Insert(request, cancellationToken);
        }

        [Authorize(Roles = "Admin")]
        public override Task<SpaceUnitImage> Update(int id, SpaceUnitImageUpdate request, CancellationToken cancellationToken = default)
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
        public async Task<ActionResult<List<Model.SpaceUnitImage>>> UploadBase64([FromBody] SpaceUnitImageInsert request)
        {
            var result = await _spaceUnitImageService.UploadBase64ImagesAsync(request);
            return Ok(result);
        }

        [AllowAnonymous]
        public override Task<PagedResult<SpaceUnitImage>> GetList([FromQuery] SpaceUnitImageSearchObject searchObject, CancellationToken cancellationToken = default)
        {
            return base.GetList(searchObject, cancellationToken);
        }

        [AllowAnonymous]
        public override Task<SpaceUnitImage> GetById(int id, CancellationToken cancellationToken = default)
        {
            return base.GetById(id, cancellationToken);
        }
    }
}
