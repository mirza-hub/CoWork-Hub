using CoWorkHub.Model;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class CountryService : BaseService<Model.Country, CountrySearchObject, Database.Country>, ICountryService
    {
        public CountryService(_210095Context context, IMapper mapper) 
            : base(context, mapper) { }

        public override IQueryable<Database.Country> AddFilter(CountrySearchObject search, IQueryable<Database.Country> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.CountryNameGTE))
            {
                query = query.Where(x => x.CountryName.StartsWith(search.CountryNameGTE));
            }

            return query;
        }
    }
}
