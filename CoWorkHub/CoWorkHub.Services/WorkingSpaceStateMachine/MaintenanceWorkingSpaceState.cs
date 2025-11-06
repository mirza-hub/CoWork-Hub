using CoWorkHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.WorkingSpaceStateMachine
{
    public class MaintenanceWorkingSpaceState : BaseWorkingSpaceState
    {
        public MaintenanceWorkingSpaceState(_210095Context context, IMapper mapper, IServiceProvider serviceProvider)
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
            var set = Context.Set<WorkingSpace>();

            var entity = set.Find(id);

            if (entity == null)
            {
                throw new Exception("Working space not found.");
            }

            entity.DeletedAt = DateTime.Now;
            entity.DeletedBy = 1;
            entity.IsDeleted = true;
            entity.StateMachine = "deleted";

            Context.Update(entity);

            Context.SaveChanges();
        }

        public override List<string> AllowedActions(Database.WorkingSpace entity)
        {
            return new List<string>() { nameof(Activate), nameof(Hide), nameof(Delete) };
        }
    }
}
