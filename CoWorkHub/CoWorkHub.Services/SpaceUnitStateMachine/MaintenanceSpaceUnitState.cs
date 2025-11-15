using CoWorkHub.Model.Exceptions;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.WorkingSpaceStateMachine
{
    public class MaintenanceSpaceUnitState : BaseSpaceUnitState
    {
        public MaintenanceSpaceUnitState(
            _210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        { }

        public override Model.SpaceUnit Activate(int id)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException("Space unit not found.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.StateMachine = "active";

            Context.SaveChanges();

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

        public override Model.SpaceUnit Hide(int id)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException("Space unit not found.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.StateMachine = "hidden";

            Context.SaveChanges();

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

        public override void Delete(int id)
        {
            var set = Context.Set<SpaceUnit>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException("Space unit not found.");
            }

            entity.DeletedAt = DateTime.Now;
            entity.IsDeleted = true;
            entity.StateMachine = "deleted";

            Context.Update(entity);

            Context.SaveChanges();
        }

        public override List<string> AllowedActions(Database.SpaceUnit entity)
        {
            return new List<string>() { nameof(Activate), nameof(Hide), nameof(Delete) };
        }
    }
}
