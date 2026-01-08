using Azure.Core;
using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
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

        public DraftSpaceUnitState(
            _210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider,
            ISpaceUnitResourceService spaceUnitResourceService) 
            : base(context, mapper, serviceProvider)
        { 
            _spaceUnitResourceService = spaceUnitResourceService;
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
