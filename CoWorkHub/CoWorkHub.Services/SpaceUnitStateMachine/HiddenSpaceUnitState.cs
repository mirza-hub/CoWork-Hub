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
    public class HiddenSpaceUnitState : BaseSpaceUnitState
    {
        public HiddenSpaceUnitState(
            _210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider)
            : base(context, mapper, serviceProvider)
        { }

        public override Model.SpaceUnit Edit(int id)
        {
            var set = Context.Set<SpaceUnit>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException("Space unit not found.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.StateMachine = "draft";

            Context.SaveChanges();

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

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

        public override Model.SpaceUnit SetMaintenance(int id)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException("Space unit not found.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.StateMachine = "maintenance";

            Context.SaveChanges();

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

        public override void Delete(int id)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException("Space unit not found.");
            }

            entity.DeletedAt = DateTime.UtcNow;
            entity.IsDeleted = true;
            entity.StateMachine = "deleted";

            Context.SaveChanges();
        }

        public override List<string> AllowedActions(Database.SpaceUnit entity)
        {
            return new List<string>() { nameof(Edit), nameof(Activate), nameof(SetMaintenance), nameof(Delete) };
        }
    }
}
