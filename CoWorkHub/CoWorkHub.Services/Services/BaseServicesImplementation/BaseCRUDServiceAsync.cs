using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services.BaseServicesImplementation
{
    public class BaseCRUDServiceAsync<TModel, TSearch, TDbEntity, TInsert, TUpdate> : BaseServiceAsync<TModel, TSearch, TDbEntity> where TModel : class where TSearch : BaseSearchObject where TDbEntity : class, ISoftDeletable
    {
        public BaseCRUDServiceAsync(_210095Context context, IMapper mapper) 
            : base(context, mapper) { }

        public virtual async Task<TModel> InsertAsync(TInsert request, CancellationToken cancellationToken = default)
        {
            TDbEntity entity = Mapper.Map<TDbEntity>(request);

            await BeforeInsertAsync(request, entity);

            Context.Add(entity);
            await Context.SaveChangesAsync(cancellationToken);

            await AfterInsertAsync(request, entity);

            return Mapper.Map<TModel>(entity);
        }
        public virtual async Task BeforeInsertAsync(TInsert request, TDbEntity entity, CancellationToken cancellationToken = default) { }
        public virtual async Task AfterInsertAsync(TInsert request, TDbEntity entity, CancellationToken cancellationToken = default) { }

        public virtual async Task<TModel> UpdateAsync(int id, TUpdate request, CancellationToken cancellationToken = default)
        {
            var set = Context.Set<TDbEntity>();

            var entity = await set.FindAsync(id, cancellationToken);

            if (entity == null)
                throw new UserException("Entiten nije pronađen");

            Mapper.Map(request, entity);

            await BeforeUpdateAsync(request, entity);

            await Context.SaveChangesAsync(cancellationToken);

            await AfterUpdateAsync(request, entity);

            return Mapper.Map<TModel>(entity);
        }

        public virtual async Task BeforeUpdateAsync(TUpdate request, TDbEntity entity, CancellationToken cancellationToken = default) { }
        public virtual async Task AfterUpdateAsync(TUpdate request, TDbEntity entity, CancellationToken cancellationToken = default) { }

        public virtual async Task DeleteAsync(int id, CancellationToken cancellationToken = default)
        {
            var entity = await Context.Set<TDbEntity>().FindAsync(id, cancellationToken);
            if (entity == null)
                throw new UserException("Entiten nije pronađen.");

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

            await Context.SaveChangesAsync(cancellationToken);

            await AfterDeleteAsync(entity, cancellationToken);
        }

        public virtual async Task AfterDeleteAsync(TDbEntity entity, CancellationToken cancellationToken) { }
    }
}
