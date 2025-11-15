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

        public virtual Model.SpaceUnit Insert(SpaceUnitInsertRequest request)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual Model.SpaceUnit Update(int id, SpaceUnitUpdateRequest request)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual Model.SpaceUnit Activate(int id)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual Model.SpaceUnit Hide(int id)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual Model.SpaceUnit Edit(int id)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual Model.SpaceUnit SetMaintenance(int id)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual void Delete(int id)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual Model.SpaceUnit Restore(int id)
        {
            throw new UserException("Method not allowed.");
        }

        public virtual List<string> AllowedActions(Database.SpaceUnit entity)
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