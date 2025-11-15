using Azure.Core;
using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Services.Auth;
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
    public class DraftSpaceUnitState : BaseSpaceUnitState
    {
        public DraftSpaceUnitState(
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

        public override Model.SpaceUnit Update(int id, SpaceUnitUpdateRequest request)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException("Space unit not found.");
            }

            if (!string.IsNullOrWhiteSpace(request.Name))
            {
                bool exists = Context.SpaceUnits.Any(x =>
                    x.WorkingSpaceId == entity.WorkingSpaceId &&
                    x.SpaceUnitId != entity.SpaceUnitId &&
                    x.Name.ToLower() == request.Name.ToLower() &&
                    !x.IsDeleted
                );

                if (exists)
                    throw new UserException("Another space unit with this name already exists in the same working space.");
            }

            Mapper.Map(request, entity);
            entity.ModifiedAt = DateTime.UtcNow;

            Context.SaveChanges();

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

        public override Model.SpaceUnit Hide(int id)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException("Working space not found.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.StateMachine = "hidden";

            Context.SaveChanges();

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

        public override void Delete(int id)
        {
            var set = Context.Set<Database.SpaceUnit>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new UserException("Working space not found.");
            }

            entity.IsDeleted = true;
            entity.DeletedAt = DateTime.UtcNow;
            entity.StateMachine = "deleted";

            Context.SaveChanges();
        }

        public override List<string> AllowedActions(Database.SpaceUnit entity)
        {
            return new List<string>() { nameof(Activate), nameof(Update), nameof(Hide), nameof(Delete) };
        }
    }
}
