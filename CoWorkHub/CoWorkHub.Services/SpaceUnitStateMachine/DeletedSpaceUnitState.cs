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
using System.Threading;
using System.Threading.Tasks;

namespace CoWorkHub.Services.WorkingSpaceStateMachine
{
    public class DeletedSpaceUnitState : BaseSpaceUnitState
    {
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;

        public DeletedSpaceUnitState(_210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService) 
            : base(context, mapper, serviceProvider)
        { 
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
        }

        public override async Task<Model.SpaceUnit> Restore(int id, CancellationToken cancellationToken)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = await set.FindAsync(id, cancellationToken);

            if (entity == null) 
            {
                throw new UserException("Prostorna jedinica nije pronađena.");
            }

            if (entity is ISoftDeletable softDeletableEntity)
            {
                softDeletableEntity.Undo();
            }

            entity.StateMachine = "hidden";

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "HIDE",
            "SpaceUnit",
            $"Prostorna jedinica sakrivena {entity.SpaceUnitId}");

            await Context.SaveChangesAsync(cancellationToken);

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

        public override Task<List<string>> AllowedActions(Database.SpaceUnit entity, CancellationToken cancellationToken)
        {
            return Task.FromResult(new List<string>()
            {
                nameof(Restore),
            });
        }
    }
}
