using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Auth;
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
    public class WorkingSpaceImagesService : BaseCRUDServiceAsync<Model.WorkingSpaceImage, WorkingSpaceImageSearchObject, WorkingSpaceImage, WorkingSpaceImageInsertRequest, WorkingSpaceImageUpdateRequest>, IWorkingSpaceImageService
    {
        private readonly IHostEnvironment _environment;
        private readonly ICurrentUserService _currentUserService;

        public WorkingSpaceImagesService(_210095Context context, 
            IMapper mapper, 
            IHostEnvironment environment,
            ICurrentUserService currentUserService)
            : base(context, mapper)
        {
            _environment = environment;
            _currentUserService = currentUserService;
        }

        public override IQueryable<WorkingSpaceImage> AddFilter(WorkingSpaceImageSearchObject search, IQueryable<WorkingSpaceImage> query)
        {
            query = base.AddFilter(search, query);

            if (search.WorkingSpaceId.HasValue)
                query = query.Where(x => x.WorkingSpacesId == search.WorkingSpaceId);

            return query;
        }

        public override async Task<Model.WorkingSpaceImage> InsertAsync(WorkingSpaceImageInsertRequest request, CancellationToken cancellationToken = default)
        {
            var result = await UploadBase64ImagesAsync(request, cancellationToken);

            return result.First();
        }

        public async Task<List<Model.WorkingSpaceImage>> UploadBase64ImagesAsync(WorkingSpaceImageInsertRequest request, CancellationToken cancellationToken = default)
        {
            var result = new List<Model.WorkingSpaceImage>();
            if (request.Base64Images == null || request.Base64Images.Count == 0)
                return result;

            string uploadFolder = Path.Combine(_environment.ContentRootPath, "wwwroot", "uploads", "workingspaces");
            Directory.CreateDirectory(uploadFolder);

            foreach (var base64 in request.Base64Images)
            {
                var base64Data = base64.Contains("base64,") ? base64.Split("base64,")[1] : base64;
                var bytes = Convert.FromBase64String(base64Data);

                string fileName = $"{Guid.NewGuid()}.png";
                string filePath = Path.Combine(uploadFolder, fileName);
                await File.WriteAllBytesAsync(filePath, bytes, cancellationToken);

                var dbEntity = new WorkingSpaceImage
                {
                    WorkingSpacesId = request.WorkingSpacesId,
                    ImagePath = $"uploads/workingspaces/{fileName}",
                    Description = request.Description ?? "nema opisa",
                    CreatedBy = (int)_currentUserService.GetUserId(),
                    CreatedAt = DateTime.Now
                };

                Context.WorkingSpaceImages.Add(dbEntity);
                await Context.SaveChangesAsync(cancellationToken);

                result.Add(Mapper.Map<Model.WorkingSpaceImage>(dbEntity));
            }

            return result;
        }
    }
}
