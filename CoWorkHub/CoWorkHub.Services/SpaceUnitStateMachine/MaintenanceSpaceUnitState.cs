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
    public class MaintenanceSpaceUnitState : BaseSpaceUnitState
    {
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;

        public MaintenanceSpaceUnitState(
            _210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService
            )
            : base(context, mapper, serviceProvider)
        { 
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
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

        public override async Task<Model.SpaceUnit> Hide(int id, CancellationToken cancellationToken)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = await set.FindAsync(id, cancellationToken);

            if (entity == null)
            {
                throw new UserException("Prostorna jedinica nije pronađena.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.StateMachine = "hidden";

            await Context.SaveChangesAsync(cancellationToken);

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "HIDE",
            "SpaceUnit",
            $"Prostorna jedinica sakrivena {entity.SpaceUnitId}");

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

        public override async Task Delete(int id, CancellationToken cancellationToken)
        {
            var set = Context.Set<SpaceUnit>();

            var entity = await set.FindAsync(id, cancellationToken);

            if (entity == null)
            {
                throw new UserException("Prostorna jedinica nije pronađena.");
            }

            entity.DeletedAt = DateTime.Now;
            entity.IsDeleted = true;
            entity.StateMachine = "deleted";

            Context.Update(entity);

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "DELETE",
            "SpaceUnit",
            $"Prostorna jedinica obrisana {entity.SpaceUnitId}");

            await Context.SaveChangesAsync(cancellationToken);
        }

        public override Task<List<string>> AllowedActions(Database.SpaceUnit entity, CancellationToken cancellationToken)
        {
            return Task.FromResult(new List<string>()
            {
                nameof(Activate),
                nameof(Hide),
                nameof(Delete)
            });
        }
    }
}
