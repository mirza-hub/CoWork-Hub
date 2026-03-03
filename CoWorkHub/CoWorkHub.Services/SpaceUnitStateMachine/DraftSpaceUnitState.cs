using Azure.Core;
using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.WorkingSpaceStateMachine
{
    public class DraftSpaceUnitState : BaseSpaceUnitState
    {
        ISpaceUnitResourceService _spaceUnitResourceService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;
        private readonly INotificationService _notificationService;

        public DraftSpaceUnitState(
            _210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider,
            ISpaceUnitResourceService spaceUnitResourceService,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService,
            INotificationService notificationService
            ) 
            : base(context, mapper, serviceProvider)
        { 
            _spaceUnitResourceService = spaceUnitResourceService;
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
            _notificationService = notificationService;
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

        public override async Task<Model.SpaceUnit> Update(int id, SpaceUnitUpdateRequest request, CancellationToken cancellationToken)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = await set.FindAsync(id, cancellationToken);

            if (entity == null)
            {
                throw new UserException("Prostorna jedinica nije pronađena.");
            }

            if (!string.IsNullOrWhiteSpace(request.Name))
            {
                bool exists = await Context.SpaceUnits.AnyAsync(x =>
                    x.WorkingSpaceId == entity.WorkingSpaceId &&
                    x.SpaceUnitId != entity.SpaceUnitId &&
                    x.Name.ToLower() == request.Name.ToLower() &&
                    !x.IsDeleted, cancellationToken
                );

                if (exists)
                    throw new UserException("Prostorna jedinica sa ovim imenom već postoji.");
            }

            Mapper.Map(request, entity);
            entity.ModifiedAt = DateTime.UtcNow;
            int _currentUserId = (int)_currentUserService.GetUserId();

            if (request.ResourcesList != null)
            {
                var existingResources = await Context.SpaceUnitResources
                    .Where(r => r.SpaceUnitId == entity.SpaceUnitId && !r.IsDeleted)
                    .ToListAsync(cancellationToken);

                var toDelete = existingResources
                    .Where(r => !request.ResourcesList.Any(rr => rr.ResourcesId == r.ResourcesId))
                    .ToList();

                foreach (var del in toDelete)
                {
                    del.IsDeleted = true;
                    del.DeletedAt = DateTime.UtcNow;
                    var resources = Context.SpaceUnitResources.Include(x => x.SpaceUnit).Include(x => x.Resources).FirstOrDefault(x => x.SpaceResourcesId == del.SpaceResourcesId);
                    _notificationService.Insert(new NotificationInsertRequest
                    {
                        UserId = _currentUserId,
                        Message = $"Uspješno ste obrisali resurs {resources.Resources.ResourceName} za prostor {resources.SpaceUnit.Name}."
                    });
                    _activityLogService.LogAsync(
                        _currentUserId,
                        "DELETE",
                        "SpaceUnitResource",
                        $"Obrisan resurs {resources.Resources.ResourceName.ToUpper()}  za prostor  {resources.SpaceUnit.Name.ToUpper()}");
                }

                var toAdd = request.ResourcesList
                    .Where(r => !existingResources.Any(er => er.ResourcesId == r.ResourcesId))
                    .ToList();

                foreach (var add in toAdd)
                {
                    var resourceRequest = new SpaceUnitResourcesInsertRequest
                    {
                        SpaceUnitId = entity.SpaceUnitId,
                        ResourcesId = add.ResourcesId
                    };

                    _spaceUnitResourceService.Insert(resourceRequest);
                }
            }

            _activityLogService.LogAsync(
            _currentUserId,
            "UPDATE",
            "SpaceUnit",
            $"Prostorna jedinica ažurirana {entity.Name.ToUpper()}");
            _notificationService.Insert(new NotificationInsertRequest
            {
                UserId = _currentUserId,
                Message = $"Uspješno ste ažurirali prostornu jedinicu {entity.Name}."
            });

            await Context.SaveChangesAsync(cancellationToken);

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

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "HIDE",
            "SpaceUnit",
            $"Prostorna jedinica sakrivena {entity.Name.ToUpper()}");
            _notificationService.Insert(new NotificationInsertRequest
            {
                UserId = _currentUserId,
                Message = $"Uspješno ste sakrili prostornu jedinicu {entity.Name}."
            });

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

            entity.IsDeleted = true;
            entity.DeletedAt = DateTime.UtcNow;
            entity.StateMachine = "deleted";

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "DELETE",
            "SpaceUnit",
            $"Prostorna jedinica obrisana {entity.Name.ToUpper()}");
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
                nameof(Activate),
                nameof(Update),
                nameof(Hide),
                nameof(Delete)
            });
        }
    }
}
