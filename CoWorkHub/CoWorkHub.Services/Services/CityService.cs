using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;

namespace CoWorkHub.Services.Services
{
    public class CityService : BaseCRUDService<Model.City, CitySearchObject, Database.City, CityInsertRequest, CityUpdateRequest>, ICityService
    {
        private readonly IGeoLocationService _geoLocationService;

        public CityService(_210095Context context, IMapper mapper, IGeoLocationService geoLocationService)
            : base(context, mapper) 
        {
            _geoLocationService = geoLocationService;
        }

        public override IQueryable<City> AddFilter(CitySearchObject search, IQueryable<City> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.CityNameGTE))
            {
                query = query.Where(x => x.CityName.ToLower().StartsWith(search.CityNameGTE.ToLower()));
            }

            return query;
        }

        public override void BeforeInsert(CityInsertRequest request, City entity)
        {
            base.BeforeInsert(request, entity);

            var existingCity = Context.Cities
                .FirstOrDefault(x => x.CityName.ToLower() == request.CityName.ToLower()
                       || x.PostalCode.ToLower() == request.PostalCode.ToLower());

            if (existingCity != null)
            {
                if (existingCity.CityName.Equals(request.CityName, StringComparison.OrdinalIgnoreCase))
                    throw new UserException("A city with this name already exists in the database.");

                if (existingCity.PostalCode.Equals(request.PostalCode, StringComparison.OrdinalIgnoreCase))
                    throw new UserException("This postal code is already assigned.");
            }

            if (!string.IsNullOrWhiteSpace(request.CityName))
            {
                var coordinates = _geoLocationService.GetCoordinatesAsync(request.CityName).Result;
                entity.Latitude = coordinates.lat;
                entity.Longitude = coordinates.lon;
            }
        }
    }
}
