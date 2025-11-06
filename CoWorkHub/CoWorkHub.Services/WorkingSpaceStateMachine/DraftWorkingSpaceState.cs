using Azure.Core;
using CoWorkHub.Model.Requests;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.WorkingSpaceStateMachine
{
    public class DraftWorkingSpaceState : BaseWorkingSpaceState
    {
        public DraftWorkingSpaceState(_210095Context context, IMapper mapper, IServiceProvider serviceProvider) 
            : base(context, mapper, serviceProvider)
        { }

        public override Model.WorkingSpace Activate(int id)
        {
            var set = Context.Set<Database.WorkingSpace>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new Exception("Working space not found.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.ModifiedBy = 1;
            entity.StateMachine = "active";

            Context.SaveChanges();

            return Mapper.Map<Model.WorkingSpace>(entity);
        }

        public override Model.WorkingSpace Update(int id, WorkingSpaceUpdateRequest request)
        {
            var set = Context.Set<Database.WorkingSpace>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new Exception("Working space not found.");
            }

            Mapper.Map(request, entity);
            entity.ModifiedAt = DateTime.UtcNow;
            entity.ModifiedBy = 1; // Treba promjenuti

            Context.SaveChanges();

            return Mapper.Map<Model.WorkingSpace>(entity);
        }

        public override Model.WorkingSpace Hide(int id)
        {
            var set = Context.Set<Database.WorkingSpace>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new Exception("Working space not found.");
            }

            entity.ModifiedAt = DateTime.UtcNow;
            entity.ModifiedBy = 1;
            entity.StateMachine = "hidden";

            Context.SaveChanges();

            return Mapper.Map<Model.WorkingSpace>(entity);
        }

        public override void Delete(int id)
        {
            var set = Context.Set<Database.WorkingSpace>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new Exception("Working space not found.");
            }

            entity.IsDeleted = true;
            entity.DeletedAt = DateTime.UtcNow;
            entity.DeletedBy = 1; //ZASAD NEK OSTANE OVAKO
            entity.StateMachine = "deleted";

            Context.SaveChanges();
        }

        public override List<string> AllowedActions(Database.WorkingSpace entity)
        {
            return new List<string>() { nameof(Activate), nameof(Update), nameof(Hide), nameof(Delete) };
        }
    }
}
