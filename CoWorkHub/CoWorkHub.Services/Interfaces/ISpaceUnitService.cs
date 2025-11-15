using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;

namespace CoWorkHub.Services.Interfaces
{
    public interface ISpaceUnitService : ICRUDService<Model.SpaceUnit, SpaceUnitSearchObject, SpaceUnitInsertRequest, SpaceUnitUpdateRequest>
    {
        public SpaceUnit Activate(int id);
        public SpaceUnit Edit(int id);
        public SpaceUnit Hide(int id);
        public SpaceUnit SetMaintenance(int id);
        public SpaceUnit Restore(int id);
        public List<string> AllowedActions(int id);
    }
}
