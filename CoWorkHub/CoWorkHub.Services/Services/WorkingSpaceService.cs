using Azure.Core;
using CoWorkHub.Model;
using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using CoWorkHub.Services.WorkingSpaceStateMachine;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace CoWorkHub.Services.Services
{
    public class WorkingSpaceService : BaseCRUDService<Model.WorkingSpace, WorkingSpaceSearchObject, Database.WorkingSpace, WorkingSpaceInsertRequest, WorkingSpaceUpdateRequest>, IWorkingSpaceService
    {
        private readonly ICurrentUserService _currentUserService;

        public WorkingSpaceService(_210095Context context, 
            IMapper mapper, 
            ICurrentUserService currentUserService) 
            : base(context, mapper) 
        {
            _currentUserService = currentUserService;
        }

        public override IQueryable<Database.WorkingSpace> AddFilter(WorkingSpaceSearchObject search, IQueryable<Database.WorkingSpace> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.NameFTS))
                query = query.Where(x => x.Name.ToLower().Contains(search.NameFTS.ToLower()));
            
            if (search.CityId.HasValue)
                query = query.Where(x => x.CityId == search.CityId.Value);

            if (!string.IsNullOrWhiteSpace(search.AddressFTS))
                query = query.Where(x => x.Address.ToLower().Contains(search.AddressFTS.ToLower()));

            if (search.IsCityIncluded == true)
                query = query.Include(x => x.City);

            //if (search.IsSpaceUnitIncluded == true)
            //    query = query.Include(x => x.SpaceUnits)
            //        .ThenInclude(xu=>xu.SpaceUnitResources)
            //        .ThenInclude(xuz=>xuz.Resources)
            //        .Include(y=>y.SpaceUnits).ThenInclude(yu=>yu.WorkspaceType);

            return query;
        }

        public override void BeforeInsert(WorkingSpaceInsertRequest request, Database.WorkingSpace entity)
        {
            base.BeforeInsert(request, entity);

            var existingWorkingSpace = Context.WorkingSpaces
               .FirstOrDefault(x => x.Name.ToLower() == request.Name.ToLower());

            if (existingWorkingSpace != null)
            {
                if (existingWorkingSpace.Name.Equals(request.Name, StringComparison.OrdinalIgnoreCase))
                    throw new UserException("Prostor sa ovim imenom već postoji u bazi.");
            }

            if (string.IsNullOrWhiteSpace(request.Address))
                throw new UserException("Adresa je obavezna.");

            if (request.Latitude < -90 || request.Latitude > 90 ||
                request.Longitude < -180 || request.Longitude > 180)
            {
                throw new UserException("Koordinate nisu validne");
            }

            entity.CreatedAt = DateTime.UtcNow;
            entity.CreatedBy = (int)_currentUserService.GetUserId();
        }

        public override void BeforeUpdate(WorkingSpaceUpdateRequest request, Database.WorkingSpace entity)
        {
            base.BeforeUpdate(request, entity);

            var existingWorkingSpace = Context.WorkingSpaces
               .FirstOrDefault(x => 
               x.Name.ToLower() == request.Name.ToLower() &&
               x.WorkingSpacesId != entity.WorkingSpacesId);

            if (existingWorkingSpace != null)
            {
                throw new UserException("Prostor sa ovim imenom već postoji u bazi.");
            }

            if (request.Latitude < -90 || request.Latitude > 90 ||
                request.Longitude < -180 || request.Longitude > 180)
            {
                throw new UserException("Koordinate nisu validne");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.ModifiedBy = _currentUserService.GetUserId();
        }

        public override void BeforeDelete(Database.WorkingSpace entity)
        {
            base.BeforeDelete(entity);

            entity.DeletedBy = _currentUserService.GetUserId();
        }

        public Model.WorkingSpace RestoreWorkingSpace(int id)
        {
            var set = Context.Set<Database.WorkingSpace>();

            var entity = set.Find(id);

            if (entity == null)
                throw new UserException("Prostor nije pronađen.");

            if (entity.IsDeleted == false)
                throw new UserException("Prostor nije moguće vratiti jer nije obrisan.");

            entity.IsDeleted = false;
            entity.DeletedAt = null;
            entity.DeletedBy = null;

            Context.SaveChanges();

            return Mapper.Map<Model.WorkingSpace>(entity);
        }
    }
}
