using CoWorkHub.Model.Exceptions;
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
    public class DeletedSpaceUnitState : BaseSpaceUnitState
    {
        public DeletedSpaceUnitState(_210095Context context, IMapper mapper, IServiceProvider serviceProvider) 
            : base(context, mapper, serviceProvider)
        { }

        public override Model.SpaceUnit Restore(int id)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = set.Find(id);

            if (entity == null) 
            {
                throw new UserException("Space unit not found.");
            }

            if (entity is ISoftDeletable softDeletableEntity)
            {
                softDeletableEntity.Undo();
            }

            entity.StateMachine = "hidden";

            Context.SaveChanges();

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

        public override List<string> AllowedActions(Database.SpaceUnit entity)
        {
            return new List<string>() { nameof(Restore) };
        }
    }
}
