﻿using Azure;
using CoWorkHub.Model;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore.Metadata;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class BaseService<TModel, TSearch, TBEntity> : IService<TModel, TSearch> where TModel : class where TSearch : BaseSearchObject where TBEntity : class
    {
        public _210095Context Context { get; set; }
        public IMapper Mapper { get; set; }
        public BaseService(_210095Context context, IMapper mapper)
        {
            Context = context;
            Mapper = mapper;
        }

        public PagedResult<TModel> GetPaged(TSearch search)
        {
            List<TModel> result = new List<TModel>();

            var query = Context.Set<TBEntity>().AsQueryable();

            query = AddFilter(search, query);

            int count = query.Count();
            var page = search?.Page ?? 1;
            var pageSize = search?.PageSize ?? 10;

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true) 
            {
                query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);                
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

        public virtual IQueryable<TBEntity> AddFilter(TSearch search, IQueryable<TBEntity> query)
        {
            return query;
        }

        public TModel GetById(int id)
        {
            var entity = Context.Set<TBEntity>().Find(id);

            if (entity != null)
                return Mapper.Map<TModel>(entity);
            else
                return null;
        }
    }
}
