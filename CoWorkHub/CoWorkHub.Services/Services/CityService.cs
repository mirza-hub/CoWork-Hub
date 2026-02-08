using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Text.RegularExpressions;

namespace CoWorkHub.Services.Services
{
    public class CityService : BaseCRUDService<Model.City, CitySearchObject, Database.City, CityInsertRequest, CityUpdateRequest>, ICityService
    {
        private readonly ILogger<CityService> _logger;
        private readonly IGeoLocationService _geoLocationService;

        public CityService(_210095Context context, 
            IMapper mapper, 
            IGeoLocationService geoLocationService,
            ILogger<CityService> logger)
            : base(context, mapper) 
        {
            _geoLocationService = geoLocationService;
            _logger = logger;
        }

        public override IQueryable<City> AddFilter(CitySearchObject search, IQueryable<City> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.CityNameGTE))
            {
                query = query.Where(x => x.CityName.ToLower().StartsWith(search.CityNameGTE.ToLower()));
            }

            if (search.IsCountryIncluded)
                query = query.Include(x => x.Country);

            return query;
        }

        public override void BeforeInsert(CityInsertRequest request, City entity)
        {
            base.BeforeInsert(request, entity);

            _logger.LogInformation($"Adding City: {entity.CityName}");

            ValidateCity(request);

            var existingCity = Context.Cities
                .FirstOrDefault(x => (x.CityName.ToLower() == request.CityName.ToLower()
                       || x.PostalCode.ToLower() == request.PostalCode.ToLower()) && x.CityId != entity.CityId);

            if (existingCity != null)
            {
                if (existingCity.CityName.Equals(request.CityName, StringComparison.OrdinalIgnoreCase))
                    throw new UserException("Grad sa tim imenom već postoji u bazi.");

                if (existingCity.PostalCode.Equals(request.PostalCode, StringComparison.OrdinalIgnoreCase))
                    throw new UserException("Ovaj poštanski broj je već zauzet.");
            }

            entity.Latitude = 0;
            entity.Longitude = 0;

            if (!string.IsNullOrWhiteSpace(request.CityName))
            {
                try
                {
                    var coordinates = _geoLocationService.GetCoordinatesAsync(request.CityName).Result;
                    entity.Latitude = coordinates.lat;
                    entity.Longitude = coordinates.lon;
                }
                catch (AggregateException ex) when (ex.InnerException is UserException)
                {
                    // Grad nije pronađen → ostaje 0,0
                }

            }

        }

        public override void BeforeUpdate(CityUpdateRequest request, City entity)
        {
            var requestUpdate = Mapper.Map<CityInsertRequest>(request);
            ValidateCity(requestUpdate);

            var existingCity = Context.Cities
                .FirstOrDefault(x => x.CityId != entity.CityId && (x.CityName.ToLower() == request.CityName.ToLower()
                       || x.PostalCode.ToLower() == request.PostalCode.ToLower()));

            if (existingCity != null)
            {
                if (existingCity.CityName.Equals(request.CityName, StringComparison.OrdinalIgnoreCase))
                    throw new UserException("Grad sa tim imenom već postoji u bazi.");

                if (existingCity.PostalCode.Equals(request.PostalCode, StringComparison.OrdinalIgnoreCase))
                    throw new UserException("Ovaj poštanski broj je već zauzet.");
            }
        }

        public Model.City RestoreCity(int id)
        {
            var set = Context.Set<Database.City>();

            var entity = set.Find(id);

            if (entity == null)
                throw new UserException("Grad nije pronađen.");

            if (entity.IsDeleted == false)
                throw new UserException("Grad nije moguće vratiti jer nije obrisan.");

            entity.IsDeleted = false;
            entity.DeletedAt = null;

            Context.SaveChanges();

            return Mapper.Map<Model.City>(entity);
        }

        private void ValidateCity(CityInsertRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.CityName))
                throw new UserException("Naziv grada je obavezan.");

            var cityName = request.CityName.Trim();

            if (cityName.Length < 2)
                throw new UserException("Naziv grada mora imati najmanje 2 slova.");

            if (!Regex.IsMatch(cityName, @"^[A-Za-zČĆŽŠĐčćžšđ\s\-]+$"))
                throw new UserException("Naziv grada smije sadržavati samo slova.");

            if (string.IsNullOrWhiteSpace(request.PostalCode))
                throw new UserException("Poštanski broj je obavezan.");

            if (!Regex.IsMatch(request.PostalCode, @"^\d{4,6}$"))
                throw new UserException("Poštanski broj mora imati 4 do 6 cifara.");

            if (request.CountryId <= 0)
                throw new UserException("Država mora biti izabrana.");
        }
    }
}
