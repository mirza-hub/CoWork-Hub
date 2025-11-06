using CoWorkHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.WorkingSpaceStateMachine
{
    public class ActiveWorkingSpaceState : BaseWorkingSpaceState
    {
        public ActiveWorkingSpaceState(_210095Context context, IMapper mapper, IServiceProvider serviceProvider) 
            : base(context, mapper, serviceProvider)
        { }

        public override Model.WorkingSpace SetMaintenance(int id)
        {
            var set = Context.Set<Database.WorkingSpace>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new Exception("Working space not found.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.ModifiedBy = 1;
            entity.StateMachine = "maintenance";

            Context.SaveChanges();

            return Mapper.Map<Model.WorkingSpace>(entity);
        }

        public override Model.WorkingSpace Hide(int id)
        {
            var set = Context.Set<Database.WorkingSpace>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new Exception("Working space not found.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.ModifiedBy = 1;
            entity.StateMachine = "hidden";

            Context.SaveChanges();

            return Mapper.Map<Model.WorkingSpace>(entity);
        }

        public override List<string> AllowedActions(Database.WorkingSpace entity)
        {
            return new List<string>() { nameof(SetMaintenance), nameof(Hide) };
        }
    }
}
