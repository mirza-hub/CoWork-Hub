using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
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
    public class InitialSpaceUnitState : BaseSpaceUnitState
    {
        public InitialSpaceUnitState(
            _210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider) 
            : base(context, mapper, serviceProvider)
        { }

        public override Model.SpaceUnit Insert(SpaceUnitInsertRequest request)
        {
            var set = Context.Set<SpaceUnit>();

            if (!Context.WorkingSpaces.Any(x => x.WorkingSpacesId == request.WorkingSpacesId))
                throw new UserException("WorkingSpace does not exist.");

            bool exists = Context.SpaceUnits.Any(x =>
                x.WorkingSpaceId == request.WorkingSpacesId &&
                x.Name.ToLower() == request.Name.ToLower() && !x.IsDeleted);

            if (exists)
                throw new UserException("A space unit with the same name already exists in this working space.");

            if (!Context.WorkspaceTypes.Any(x => x.WorkspaceTypeId == request.WorkspaceTypeId))
                throw new UserException("WorkspaceType does not exist.");

            var entity = Mapper.Map<SpaceUnit>(request);
            entity.CreatedAt = DateTime.UtcNow;
            entity.StateMachine = "draft";
            set.Add(entity);
            Context.SaveChanges();

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

        public override List<string> AllowedActions(Database.SpaceUnit entity)
        {
            return new List<string>() { nameof(Insert) };
        }
    }
}
