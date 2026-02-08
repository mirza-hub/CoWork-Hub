using CoWorkHub.Model.Exceptions;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services;
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
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;

        public HiddenSpaceUnitState(
            _210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService)
            : base(context, mapper, serviceProvider)
        {
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
        }

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

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "EDIT",
            "SpaceUnit",
            $"Prostorna jedinica prebačena u draft {entity.SpaceUnitId}");

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

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "ACTIVATE",
            "SpaceUnit",
            $"Prostorna jedinica aktvirana {entity.SpaceUnitId}");

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

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "MAINTENANCE",
            "SpaceUnit",
            $"Prostorna jedinica prebačena u stanje održavanja {entity.SpaceUnitId}");

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

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "EDIT",
            "SpaceUnit",
            $"Prostorna jedinica obrisan {entity.SpaceUnitId}");

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
