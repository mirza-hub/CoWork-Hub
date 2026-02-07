using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using System.Text.RegularExpressions;

namespace CoWorkHub.Services.Services
{
    public class CountryService : BaseCRUDService<Model.Country, CountrySearchObject, Database.Country, CountryInsertRequest, CountryUpdateRequest>, ICountryService
    {
        public CountryService(_210095Context context, IMapper mapper) 
            : base(context, mapper) { }

        public override IQueryable<Database.Country> AddFilter(CountrySearchObject search, IQueryable<Database.Country> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.CountryNameGTE))
            {
                query = query.Where(x => x.CountryName.ToLower().StartsWith(search.CountryNameGTE.ToLower()));
            }

            return query;
        }

        public override void BeforeInsert(CountryInsertRequest request, Country entity)
        {
            base.BeforeInsert(request, entity);

            ValidateCountryName(request.CountryName);

            var existingCountry = Context.Countries
                .FirstOrDefault(x => x.CountryName.ToLower() == request.CountryName.ToLower());

            if (existingCountry != null)
            {
                if (existingCountry.CountryName.Equals(request.CountryName, StringComparison.OrdinalIgnoreCase))
                    throw new UserException("Država sa tim imenom već postoji u bazi");
            }
        }

        public override void BeforeUpdate(CountryUpdateRequest request, Country entity)
        {
            base.BeforeUpdate(request, entity);

            ValidateCountryName(request.CountryName);

            var existingCountry = Context.Countries
                .FirstOrDefault(x => (x.CountryName.ToLower() == request.CountryName.ToLower()) && x.CountryId!=entity.CountryId);

            if (existingCountry != null)
            {
                throw new UserException("Država sa tim imenom već postoji u bazi");
            }
        }

        public Model.Country RestoreCountry(int id)
        {
            var set = Context.Set<Database.Country>();

            var entity = set.Find(id);

            if (entity == null)
                throw new UserException("Država nije pronađen.");

            if (entity.IsDeleted == false)
                throw new UserException("Državu nije moguće vratiti jer nije obrisana.");

            entity.IsDeleted = false;
            entity.DeletedAt = null;

            Context.SaveChanges();

            return Mapper.Map<Model.Country>(entity);
        }

        private void ValidateCountryName(string countryName)
        {
            if (string.IsNullOrWhiteSpace(countryName))
                throw new UserException("Naziv države je obavezan.");

            var trimmed = countryName.Trim();

            if (trimmed.Length < 3)
                throw new UserException("Naziv države mora imati najmanje 3 slova.");

            var regex = new Regex(@"^[A-Za-zČĆŽŠĐčćžšđ\s\-]+$");

            if (!regex.IsMatch(trimmed))
                throw new UserException("Naziv države smije sadržavati samo slova.");
        }

    }
}
