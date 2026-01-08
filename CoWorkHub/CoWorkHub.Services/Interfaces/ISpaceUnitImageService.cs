using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Interfaces
{
    public interface ISpaceUnitImageService : ICRUDServiceAsync<Model.SpaceUnitImage, SpaceUnitImageSearchObject, SpaceUnitImageInsertRequest, SpaceUnitImageUpdateRequest>
    {
        Task<List<Model.SpaceUnitImage>> UploadBase64ImagesAsync(SpaceUnitImageInsertRequest request, CancellationToken cancellationToken = default);
    }
}
