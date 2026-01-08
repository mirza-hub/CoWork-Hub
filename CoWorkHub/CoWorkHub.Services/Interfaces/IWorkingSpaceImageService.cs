using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;

namespace CoWorkHub.Services.Interfaces
{
    public interface IWorkingSpaceImageService : ICRUDServiceAsync<Model.WorkingSpaceImage, WorkingSpaceImageSearchObject, WorkingSpaceImageInsertRequest, WorkingSpaceImageUpdateRequest>
    {
        Task<List<Model.WorkingSpaceImage>> UploadBase64ImagesAsync(WorkingSpaceImageInsertRequest request, CancellationToken cancellationToken = default);
    }
}
