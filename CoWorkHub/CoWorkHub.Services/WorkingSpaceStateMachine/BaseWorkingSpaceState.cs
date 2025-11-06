using CoWorkHub.Model.Requests;
using CoWorkHub.Services.Database;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.WorkingSpaceStateMachine
{
    public class BaseWorkingSpaceState
    {
        public _210095Context Context { get; set; }
        public IMapper Mapper { get; set; }
        public IServiceProvider ServiceProvider { get; set; }

        public BaseWorkingSpaceState(_210095Context context, IMapper mapper, IServiceProvider serviceProvider)
        {
            Context = context;
            Mapper = mapper;
            ServiceProvider = serviceProvider;
        }

        public virtual Model.WorkingSpace Insert(WorkingSpaceInsertRequest request)
        {
            throw new Exception("Method not allowed.");
        }

        public virtual Model.WorkingSpace Update(int id, WorkingSpaceUpdateRequest request)
        {
            throw new Exception("Method not allowed.");
        }

        public virtual Model.WorkingSpace Activate(int id)
        {
            throw new Exception("Method not allowed.");
        }

        public virtual Model.WorkingSpace Hide(int id)
        {
            throw new Exception("Method not allowed.");
        }

        public virtual Model.WorkingSpace Edit(int id)
        {
            throw new Exception("Method not allowed.");
        }

        public virtual Model.WorkingSpace SetMaintenance(int id)
        {
            throw new Exception("Method not allowed.");
        }

        public virtual void Delete(int id)
        {
            throw new Exception("Method not allowed.");
        }

        public virtual Model.WorkingSpace Restore(int id)
        {
            throw new Exception("Method not allowed.");
        }

        public virtual List<string> AllowedActions(Database.WorkingSpace entity)
        {
            throw new Exception("Method not allowed.");
        }

        public BaseWorkingSpaceState CreateState(string stateName)
        {
            switch (stateName)
            {
                case "initial":
                    return ServiceProvider.GetService<InitialWorkingSpaceState>();
                case "draft":
                    return ServiceProvider.GetService<DraftWorkingSpaceState>();
                case "active":
                    return ServiceProvider.GetService<ActiveWorkingSpaceState>();
                case "hidden":
                    return ServiceProvider.GetService<HiddenWorkingSpaceState>();
                case "maintenance":
                    return ServiceProvider.GetService<MaintenanceWorkingSpaceState>();
                case "deleted":
                    return ServiceProvider.GetService<DeletedWorkingSpaceState>();
                default: throw new Exception("State not recognized");
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