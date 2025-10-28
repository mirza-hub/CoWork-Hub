﻿using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class BaseCRUDController<TModel, TSearch, TInsert, TUpdate> 
        : BaseController<TModel, TSearch> where TSearch : BaseSearchObject where TModel : class
    {
        protected new ICRUDService<TModel, TSearch, TInsert, TUpdate> _service;

        public BaseCRUDController(ICRUDService<TModel, TSearch, TInsert, TUpdate> service)
            : base(service)
        {
            _service = service;
        }

        [HttpPost]
        public virtual TModel Insert(TInsert request)
        {
            return _service.Insert(request);
        }

        [HttpPut("{id}")]
        public virtual TModel Update(int id, TUpdate request)
        {
            return _service.Update(id, request);
        }

        [HttpDelete("{id}")]
        public virtual void Delete(int id) 
        {
            _service.Delete(id);
        }
    }
}
