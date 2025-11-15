using Azure;
using CoWorkHub.Model;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore.Metadata;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services.BaseServicesImplementation
{
    public abstract class BaseService<TModel, TSearch, TDbBEntity> : IService<TModel, TSearch> where TModel : class where TSearch : BaseSearchObject where TDbBEntity : class, ISoftDeletable
    {
        public _210095Context Context { get; set; }
        public IMapper Mapper { get; set; }
        public BaseService(_210095Context context, IMapper mapper)
        {
            Context = context;
            Mapper = mapper;
        }

        public virtual PagedResult<TModel> GetPaged(TSearch search)
        {
            List<TModel> result = new List<TModel>();

            var query = Context.Set<TDbBEntity>().AsQueryable();

            query = AddFilter(search, query);

            int count = query.Count();

            if (!string.IsNullOrEmpty(search?.OrderBy) && !string.IsNullOrEmpty(search?.SortDirection))
            {
                query = ApplySorting(query, search.OrderBy, search.SortDirection);
            }
            
            var page = search?.Page ?? 1;
            var pageSize = search?.PageSize ?? 10;

            if (search?.RetrieveAll != true)
            {
                query = query.Skip((page - 1) * pageSize).Take(pageSize);
            }

            var list = query.ToList();
            result = Mapper.Map(list, result);

            PagedResult<TModel> pagedResult = new PagedResult<TModel>();
            pagedResult.ResultList = result;
            pagedResult.Count = count;
            pagedResult.Page = page;
            pagedResult.PageSize = pageSize;
            pagedResult.TotalPages = (int)Math.Ceiling(count / (double)pageSize);
            pagedResult.HasPreviousPage = page > 1;
            pagedResult.HasNextPage = page < (int)Math.Ceiling(count / (double)pageSize);

            return pagedResult;
        }

        public virtual IQueryable<TDbBEntity> AddFilter(TSearch search, IQueryable<TDbBEntity> query)
        {
            if (search.IsDeleted.HasValue)
            {
                query = query.Where(x => x.IsDeleted == search.IsDeleted.Value);
            }
            else
            {
                query = query.Where(x => x.IsDeleted == false);
            }

            return query;
        }

        public virtual TModel GetById(int id)
        {
            var entity = Context.Set<TDbBEntity>().Find(id);

            if (entity != null)
                return Mapper.Map<TModel>(entity);
            else
                return null!;
        }

        public IQueryable<TDbBEntity> ApplySorting(IQueryable<TDbBEntity> query, string sortColumn, string sortDirection)
        {
            var entityType = typeof(TDbBEntity);
            var property = entityType.GetProperty(sortColumn);
            if (property == null) return query;

            var parameter = Expression.Parameter(entityType, "x");
            var propertyAccess = Expression.MakeMemberAccess(parameter, property);
            var orderByExpression = Expression.Lambda(propertyAccess, parameter);

            string methodName = sortDirection.ToLower() switch
            {
                "desc" or "descending" => "OrderByDescending",
                "asc" or "ascending" => "OrderBy",
                _ => ""
            };

            if (string.IsNullOrEmpty(methodName)) return query;

            var resultExpression = Expression.Call(
                typeof(Queryable),
                methodName,
                new Type[] { entityType, property.PropertyType },
                query.Expression,
                Expression.Quote(orderByExpression)
            );

            return query.Provider.CreateQuery<TDbBEntity>(resultExpression);
        }

    }
}
