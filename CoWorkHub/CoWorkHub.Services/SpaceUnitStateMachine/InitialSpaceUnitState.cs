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
using System.Runtime.CompilerServices;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace CoWorkHub.Services.WorkingSpaceStateMachine
{
    public class InitialSpaceUnitState : BaseSpaceUnitState
    {
        ISpaceUnitImageService _spaceUnitImageService;
        ISpaceUnitResourceService _spaceUnitResourceService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;

        public InitialSpaceUnitState(
            _210095Context context, 
            IMapper mapper, 
            IServiceProvider serviceProvider,
            ISpaceUnitImageService spaceUnitImageService,
            ISpaceUnitResourceService spaceUnitResourceService,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService
            ) 
            : base(context, mapper, serviceProvider)
        {
            _spaceUnitImageService = spaceUnitImageService;
            _spaceUnitResourceService = spaceUnitResourceService;
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
        }

        public override async Task<Model.SpaceUnit> Insert(SpaceUnitInsertRequest request, CancellationToken cancellationToken)
        {
            var set = Context.Set<SpaceUnit>();

            if (!Context.WorkingSpaces.Any(x => x.WorkingSpacesId == request.WorkingSpaceId))
                throw new UserException("Prostor ne postoji.");

            bool exists = Context.SpaceUnits.Any(x =>
                x.WorkingSpaceId == request.WorkingSpaceId &&
                x.Name.ToLower() == request.Name.ToLower() && !x.IsDeleted);

            if (exists)
                throw new UserException("Prostorna jedinica već postoji.");

            if (!Context.WorkspaceTypes.Any(x => x.WorkspaceTypeId == request.WorkspaceTypeId))
                throw new UserException("Tip prostora ne postoji.");

            var entity = Mapper.Map<SpaceUnit>(request);
            entity.CreatedAt = DateTime.UtcNow;
            entity.StateMachine = "draft";
            set.Add(entity);
            await Context.SaveChangesAsync(cancellationToken);

            if (request.Base64Images != null && request.Base64Images.Any())
            {
                    var imgRequest = new SpaceUnitImageInsertRequest
                    {
                        SpaceUnitId = entity.SpaceUnitId,
                        Base64Images = request.Base64Images
                    };

                    await _spaceUnitImageService.UploadBase64ImagesAsync(imgRequest);
            }

            if (request.ResourcesList != null && request.ResourcesList.Any())
            {
                foreach (var res in request.ResourcesList)
                {
                    var resourceRequest = new SpaceUnitResourcesInsertRequest
                    {
                        SpaceUnitId = entity.SpaceUnitId,
                        ResourcesId = res.ResourcesId
                    };

                    _spaceUnitResourceService.Insert(resourceRequest);
                }
            }

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CREATE",
            "SpaceUnit",
            $"Kreiran nova Prostorna jedinica {entity.SpaceUnitId}");

            return Mapper.Map<Model.SpaceUnit>(entity);
        }

        public override Task<List<string>> AllowedActions(Database.SpaceUnit entity, CancellationToken cancellationToken)
        {
            return Task.FromResult(new List<string>()
            {
                nameof(Insert)
            });
        }
    }
}
