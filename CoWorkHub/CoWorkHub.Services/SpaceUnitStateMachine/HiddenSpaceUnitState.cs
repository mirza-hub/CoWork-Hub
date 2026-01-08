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

        public override async Task<Model.SpaceUnit> Edit(int id, CancellationToken cancellationToken)
        {
            var set = Context.Set<SpaceUnit>();

            var entity = await set.FindAsync(id, cancellationToken);

            if (entity == null)
            {
                throw new UserException("Prostorna jedinica nije pronađena.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.StateMachine = "draft";

            await Context.SaveChangesAsync(cancellationToken);

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

        public override async Task<Model.SpaceUnit> Activate(int id, CancellationToken cancellationToken)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = await set.FindAsync(id, cancellationToken);

            if (entity == null)
            {
                throw new UserException("Prostorna jedinica nije pronađena.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.StateMachine = "active";

            await Context.SaveChangesAsync(cancellationToken);

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

        public override async Task<Model.SpaceUnit> SetMaintenance(int id, CancellationToken cancellationToken)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = await set.FindAsync(id, cancellationToken);

            if (entity == null)
            {
                throw new UserException("Prostorna jedinica nije pronađena.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.StateMachine = "maintenance";

            await Context.SaveChangesAsync(cancellationToken);

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

        public override async Task Delete(int id, CancellationToken cancellationToken)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = await set.FindAsync(id, cancellationToken);

            if (entity == null)
            {
                throw new UserException("Prostorna jedinica nije pronađena.");
            }

            entity.DeletedAt = DateTime.UtcNow;
            entity.IsDeleted = true;
            entity.StateMachine = "deleted";

            await Context.SaveChangesAsync(cancellationToken);
        }

        public override Task<List<string>> AllowedActions(Database.SpaceUnit entity, CancellationToken cancellationToken)
        {
            return Task.FromResult(new List<string>()
            {
                nameof(Edit),
                nameof(Activate),
                nameof(SetMaintenance),
                nameof(Delete)
            });
        }
    }
}
