using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.WorkingSpaceStateMachine
{
    public class DeletedWorkingSpaceState : BaseWorkingSpaceState
    {
        public DeletedWorkingSpaceState(_210095Context context, IMapper mapper, IServiceProvider serviceProvider) 
            : base(context, mapper, serviceProvider)
        { }

        public override Model.WorkingSpace Restore(int id)
        {
            var set = Context.Set<Database.WorkingSpace>();

            var entity = set.Find(id);

            if (entity == null) 
            {
                throw new Exception("Working space not found.");
            }

            if (entity is ISoftDeletable softDeletableEntity)
            {
                softDeletableEntity.Undo();
            }

            entity.DeletedBy = null;
            entity.StateMachine = "hidden";

            Context.SaveChanges();

            return Mapper.Map<Model.WorkingSpace>(entity);
        }

        public override List<string> AllowedActions(Database.WorkingSpace entity)
        {
            return new List<string>() { nameof(Restore) };
        }
    }
}
