using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;

namespace CoWorkHub.Services.Interfaces
{
    public interface IWorkingSpaceService : ICRUDService<WorkingSpace, WorkingSpaceSearchObject, WorkingSpaceInsertRequest, WorkingSpaceUpdateRequest>
    {
        public WorkingSpace Activate(int id);
        public WorkingSpace Edit(int id);
        public WorkingSpace Hide(int id);
        public WorkingSpace SetMaintenance(int id);
        public WorkingSpace Restore(int id);
        public List<string> AllowedActions(int id);
    }
}
