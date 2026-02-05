using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;

namespace CoWorkHub.Services.Interfaces
{
    public interface ISpaceUnitService : ICRUDServiceAsync<Model.SpaceUnit, SpaceUnitSearchObject, SpaceUnitInsertRequest, SpaceUnitUpdateRequest>
    {
        public Task<SpaceUnit> Activate(int id, CancellationToken cancellationToken);
        public Task<SpaceUnit> Edit(int id, CancellationToken cancellationToken);
        public Task<SpaceUnit> Hide(int id, CancellationToken cancellationToken);
        public Task<SpaceUnit> SetMaintenance(int id, CancellationToken cancellationToken);
        public Task<SpaceUnit> Restore(int id, CancellationToken cancellationToken);
        public Task<List<string>> AllowedActions(int id, CancellationToken cancellationToken);
        Task<List<DayAvailability>> GetAvailability(int spaceUnitId, DateTime from, DateTime to, int requestedPeopleCount);
        //public Task<List<DayAvailability>> GetAvailabilityForMonth(SpaceUnitSearchObject search);
    }
}
