using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Services.Database;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;

namespace CoWorkHub.Services.WorkingSpaceStateMachine
{
    public class BaseSpaceUnitState
    {
        public _210095Context Context { get; set; }
        public IMapper Mapper { get; set; }
        public IServiceProvider ServiceProvider { get; set; }

        public BaseSpaceUnitState(_210095Context context, IMapper mapper, IServiceProvider serviceProvider)
        {
            Context = context;
            Mapper = mapper;
            ServiceProvider = serviceProvider;
        }

        public virtual Task<Model.SpaceUnit> Insert(SpaceUnitInsertRequest request, CancellationToken cancellationToken)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual Task<Model.SpaceUnit> Update(int id, SpaceUnitUpdateRequest request, CancellationToken cancellationToken)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual Task<Model.SpaceUnit> Activate(int id, CancellationToken cancellationToken)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual Task<Model.SpaceUnit> Hide(int id, CancellationToken cancellationToken)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual Task<Model.SpaceUnit> Edit(int id, CancellationToken cancellationToken)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual Task<Model.SpaceUnit> SetMaintenance(int id, CancellationToken cancellationToken)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual async Task Delete(int id, CancellationToken cancellationToken)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual Task<Model.SpaceUnit> Restore(int id, CancellationToken cancellationToken)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual Task<List<string>> AllowedActions(Database.SpaceUnit entity, CancellationToken cancellationToken)
        {
            throw new UserException("Method not allowed.");
        }

        public BaseSpaceUnitState CreateState(string stateName)
        {
            switch (stateName)
            {
                case "initial":
                    return ServiceProvider.GetService<InitialSpaceUnitState>();
                case "draft":
                    return ServiceProvider.GetService<DraftSpaceUnitState>();
                case "active":
                    return ServiceProvider.GetService<ActiveSpaceUnitState>();
                case "hidden":
                    return ServiceProvider.GetService<HiddenSpaceUnitState>();
                case "maintenance":
                    return ServiceProvider.GetService<MaintenanceSpaceUnitState>();
                case "deleted":
                    return ServiceProvider.GetService<DeletedSpaceUnitState>();
                default: throw new UserException("State not recognized");
            }
        }
    }
}
//States -> Initial, Draft, Active, Maintenance, Hidden, Deleted

//Initial -> Draft(Insert)
//Draft -> Active(Activate), Hidden(Hide), Deleted(Delete), remain in the same state(Update)
//Active -> Hidden(Hide), Maintenance(SetMaintenance)
//Maintenance -> Active(Activate), Hidden(Hide), Deleted(Delete)
//Hidden -> Draft(Edit), Deleted(Delete), Active(Activate), Maintenance(SetMaintenance)
//Deleted -> Hidden(Hide)