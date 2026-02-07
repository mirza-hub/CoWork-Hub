using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;

namespace CoWorkHub.Services.Interfaces
{
    public interface IWorkingSpaceService : ICRUDService<WorkingSpace, WorkingSpaceSearchObject, WorkingSpaceInsertRequest, WorkingSpaceUpdateRequest>
    {
        WorkingSpace RestoreWorkingSpace(int id);
    }
}
