using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using MapsterMapper;

namespace CoWorkHub.Services.Services.BaseServicesImplementation
{
    public abstract class BaseCRUDService<TModel, TSearch, TDbEntity, TInsert, TUpdate>
        : BaseService<TModel, TSearch, TDbEntity> where TModel : class
        where TSearch : BaseSearchObject where TDbEntity : class
    {
        protected BaseCRUDService(_210095Context context, IMapper mapper) 
            : base(context, mapper) { }

        public virtual TModel Insert(TInsert request)
        {
            TDbEntity entity = Mapper.Map<TDbEntity>(request!);
         
            BeforeInsert(request, entity);

            Context.Add(entity);
            Context.SaveChanges();

            AfterInsert(request, entity);

            return Mapper.Map<TModel>(entity);
        }

        public virtual void BeforeInsert(TInsert request, TDbEntity entity) { }
        public virtual void AfterInsert(TInsert request, TDbEntity entity) { }

        public virtual TModel Update(int id, TUpdate request)
        {
            var set = Context.Set<TDbEntity>();

            var entity = set.Find(id);

            if (entity == null)
                throw new UserException("Entity not found.");

            Mapper.Map(request, entity);

            BeforeUpdate(request, entity);

            Context.SaveChanges();

            AfterUpdate(request, entity);

            return Mapper.Map<TModel>(entity);
        }

        public virtual void BeforeUpdate(TUpdate request, TDbEntity entity) { }
        public virtual void AfterUpdate(TUpdate request, TDbEntity entity) { }

        public virtual void Delete(int id)
        {
            var entity = Context.Set<TDbEntity>().Find(id);

            if (entity == null)
                throw new UserException("Entity not found.");

            BeforeDelete(entity);

            if (entity is ISoftDeletable softDeletableEntity)
            {
                softDeletableEntity.IsDeleted = true;
                softDeletableEntity.DeletedAt = DateTime.Now;

                Context.Update(entity);
            }
            else
            {
                Context.Remove(entity);
            }

            Context.SaveChanges();
            AfterDelete(entity);
        }

        public virtual void BeforeDelete(TDbEntity entity) { }
        public virtual void AfterDelete(TDbEntity entity) { }
    }
}
