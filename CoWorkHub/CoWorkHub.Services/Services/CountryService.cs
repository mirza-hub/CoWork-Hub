using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;

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

            var existingCountry = Context.Countries
                .FirstOrDefault(x => x.CountryName.ToLower() == request.CountryName.ToLower());

            if (existingCountry != null)
            {
                if (existingCountry.CountryName.Equals(request.CountryName, StringComparison.OrdinalIgnoreCase))
                    throw new UserException("A country with this name already exists in the database.");
            }
        }

        public override void BeforeUpdate(CountryUpdateRequest request, Country entity)
        {
            base.BeforeUpdate(request, entity);

            var existingCountry = Context.Countries
                .FirstOrDefault(x => x.CountryName.ToLower() == request.CountryName.ToLower());

            if (existingCountry != null)
            {
                throw new UserException("Another country with this name already exists in the database.");
            }
        }
    }
}
