using CoWorkHub.Model.Requests;
using CoWorkHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.WorkingSpaceStateMachine
{
    public class InitialWorkingSpaceState : BaseWorkingSpaceState
    {
        public InitialWorkingSpaceState(_210095Context context, IMapper mapper, IServiceProvider serviceProvider) 
            : base(context, mapper, serviceProvider)
        { }

        public override Model.WorkingSpace Insert(WorkingSpaceInsertRequest request)
        {
            var set = Context.Set<WorkingSpace>();
            var entity = Mapper.Map<WorkingSpace>(request);

            var existingWorkingSpace = Context.WorkingSpaces
                .FirstOrDefault(x => x.Name.ToLower() == request.Name.ToLower());

            if (existingWorkingSpace != null)
            {
                throw new Exception("A Working space with this name already exists in the database.");
            }

            entity.CreatedBy = 1; //SAD ZA SAD NEK OSTANE KEC DOK SE NE IMPLEMENTIRA LOGOVANJE KORISNIKA
            entity.CreatedAt = DateTime.UtcNow;
            entity.StateMachine = "draft";
            set.Add(entity);
            Context.SaveChanges();

            return Mapper.Map<Model.WorkingSpace>(entity);
        }

        public override List<string> AllowedActions(Database.WorkingSpace entity)
        {
            return new List<string>() { nameof(Insert) };
        }
    }
}
