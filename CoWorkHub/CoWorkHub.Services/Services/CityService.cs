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
    public class CityService : BaseService<Model.City, CitySearchObject, Database.City>, ICityService
    {
        public CityService(_210095Context context, IMapper mapper)
            : base(context, mapper) { }

        public override IQueryable<City> AddFilter(CitySearchObject search, IQueryable<City> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.CityNameGTE))
            {
                query = query.Where(x => x.CityName.ToLower().StartsWith(search.CityNameGTE.ToLower()));
            }

            return query;
        }
    }
}
