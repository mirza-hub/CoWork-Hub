using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;

namespace CoWorkHub.Services.Interfaces
{
    public interface IResourcesService : ICRUDService<Resource, ResourcesSearchObject, ResourcesInsertRequest, ResourcesUpdateRequest>
    { 
        Resource RestoreResource(int id);
    }
}
