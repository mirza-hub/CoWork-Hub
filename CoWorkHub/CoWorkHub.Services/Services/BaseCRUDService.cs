using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public abstract class BaseCRUDService<TModel, TSearch, TDbEntity, TInsert, TUpdate>
        : BaseService<TModel, TSearch, TDbEntity> where TModel : class
        where TSearch : BaseSearchObject where TDbEntity : class
    {
        protected BaseCRUDService(_210095Context context, IMapper mapper) 
            : base(context, mapper) { }

        public virtual TModel Insert(TInsert request)
        {
            TDbEntity entity = Mapper.Map<TDbEntity>(request);
         
            BeforeInsert(request, entity);

            Context.Add(entity);
            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }

        public virtual void BeforeInsert(TInsert request, TDbEntity entity) { }

        public virtual TModel Update(int id, TUpdate request)
        {
            var set = Context.Set<TDbEntity>();

            var entity = set.Find(id);

            Mapper.Map(request, entity);

            BeforeUpdate(request, entity);

            Context.SaveChanges();

            return Mapper.Map<TModel>(entity);
        }

        public virtual void BeforeUpdate(TUpdate request, TDbEntity entity) { }

        public virtual void Delete(int id)
        {
            var entity = Context.Set<TDbEntity>().Find(id);

            if (entity == null)
                throw new Exception("Not found");

            BeforeDelete(entity);

            Context.Remove(entity);
            Context.SaveChanges();
        }

        public virtual void BeforeDelete(TDbEntity entity) { }
    }
}
