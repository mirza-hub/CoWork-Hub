using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;

namespace CoWorkHub.Services.Interfaces
{
    public interface IResourcesService : ICRUDService<Resource, ResourcesSearchObject, ResourcesInsertRequest, ResourcesUpdateRequest>
    {  }
}
