using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
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
        private readonly INotificationService _notificationService;

        public HiddenSpaceUnitState(
            _210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService,
            INotificationService notificationService
            )
            : base(context, mapper, serviceProvider)
        {
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
            _notificationService = notificationService;
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
            $"Prostorna jedinica prebačena u draft {entity.Name.ToUpper()}");
            _notificationService.Insert(new NotificationInsertRequest
            {
                UserId = _currentUserId,
                Message = $"Uspješno ste prostornu jedinicu prebacili u draft {entity.Name}."
            });

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
            $"Prostorna jedinica aktvirana {entity.Name.ToUpper()}");
            _notificationService.Insert(new NotificationInsertRequest
            {
                UserId = _currentUserId,
                Message = $"Uspješno ste aktivirali prostornu jedinicu {entity.Name}."
            });

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
            $"Prostorna jedinica prebačena u stanje održavanja {entity.Name.ToUpper()}");
            _notificationService.Insert(new NotificationInsertRequest
            {
                UserId = _currentUserId,
                Message = $"Uspješno ste prostornu jedinicu prebacili u stanje održavanja {entity.Name}."
            });

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
            $"Prostorna jedinica obrisan {entity.Name.ToUpper()}");
            _notificationService.Insert(new NotificationInsertRequest
            {
                UserId = _currentUserId,
                Message = $"Uspješno ste obrisali prostornu jedinicu {entity.Name}."
            });

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
