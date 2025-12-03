using CoWorkHub.Model;
using CoWorkHub.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Interfaces.BaseServicesInterfaces
{
    public interface IServiceAsync<TModel, TSearch> where TSearch : BaseSearchObject
    {
        public Task<PagedResult<TModel>> GetPagedAsync(TSearch search, CancellationToken cancellationToken = default);
        public Task<TModel> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    }
}
