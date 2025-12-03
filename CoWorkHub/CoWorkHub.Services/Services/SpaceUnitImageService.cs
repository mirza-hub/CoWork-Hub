using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using Microsoft.Extensions.Hosting;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class SpaceUnitImageService : BaseCRUDServiceAsync<Model.SpaceUnitImage, SpaceUnitImageSearchObject, SpaceUnitImage, SpaceUnitImageInsert, SpaceUnitImageUpdate>, ISpaceUnitImageService
    {
        private readonly IHostEnvironment _environment;

        public SpaceUnitImageService(_210095Context context, IMapper mapper, IHostEnvironment environment)
            : base(context, mapper)
        {
            _environment = environment;
        }

        public override IQueryable<SpaceUnitImage> AddFilter(SpaceUnitImageSearchObject search, IQueryable<SpaceUnitImage> query)
        {
            query = base.AddFilter(search, query);

            if(search.SpaceUnitId.HasValue)
                query = query.Where(x => x.SpaceUnitId == search.SpaceUnitId);

            return query;
        }

        public override async Task<Model.SpaceUnitImage> InsertAsync(SpaceUnitImageInsert request, CancellationToken cancellationToken = default)
        {
            var result = await UploadBase64ImagesAsync(request, cancellationToken);

            return result.First();
        }

        public async Task<List<Model.SpaceUnitImage>> UploadBase64ImagesAsync(SpaceUnitImageInsert request, CancellationToken cancellationToken = default)
        {
            var result = new List<Model.SpaceUnitImage>();
            if (request.Base64Images == null || request.Base64Images.Count == 0)
                return result;

            string uploadFolder = Path.Combine(_environment.ContentRootPath, "wwwroot", "uploads", "spaceunits");
            Directory.CreateDirectory(uploadFolder);

            foreach (var base64 in request.Base64Images)
            {
                var base64Data = base64.Contains("base64,") ? base64.Split("base64,")[1] : base64;
                var bytes = Convert.FromBase64String(base64Data);

                string fileName = $"{Guid.NewGuid()}.png";
                string filePath = Path.Combine(uploadFolder, fileName);
                await File.WriteAllBytesAsync(filePath, bytes, cancellationToken);

                var dbEntity = new SpaceUnitImage
                {
                    SpaceUnitId = request.SpaceUnitId,
                    ImagePath = $"uploads/spaceunits/{fileName}",
                    Description = request.Description,
                    CreatedAt = DateTime.Now
                };

                Context.SpaceUnitImages.Add(dbEntity);
                await Context.SaveChangesAsync(cancellationToken);

                result.Add(Mapper.Map<Model.SpaceUnitImage>(dbEntity));
            }

            return result;
        }
    }
}
