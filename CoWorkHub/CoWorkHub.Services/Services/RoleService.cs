using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class RoleService : BaseCRUDService<Model.Role, RoleSearchObject, Database.Role, RoleInsertRequest, RoleUpdateRequest>, IRoleService
    {
        public RoleService(_210095Context context, IMapper mapper) 
            : base(context, mapper)
        { }

        public override IQueryable<Role> AddFilter(RoleSearchObject search, IQueryable<Role> query)
        {
            query = base.AddFilter(search, query);

            if (!string.IsNullOrWhiteSpace(search.RoleNameGTE))
            {
                query = query.Where(x => x.RoleName.ToLower().StartsWith(search.RoleNameGTE.ToLower()));
            }

            return query;
        }

        public override void BeforeInsert(RoleInsertRequest request, Role entity)
        {
            base.BeforeInsert(request, entity);

            var existingRole = Context.Roles
                .FirstOrDefault(x => x.RoleName.ToLower() == request.RoleName.ToLower());

            if (existingRole != null)
            {
                throw new UserException("Uloga sa ovim imenom već postoji u bazi.");
            }

            entity.IsDeleted = false;
        }

        public override void BeforeUpdate(RoleUpdateRequest request, Role entity)
        {
            base.BeforeUpdate(request, entity);

            var existingRole = Context.Roles
                .FirstOrDefault(x => x.RoleName.ToLower() == request.RoleName.ToLower() && x.RolesId != entity.RolesId);

            if (existingRole != null)
            {
                throw new UserException("Uloga sa ovim imenom već postoji u bazi.");
            }
        }
    }
}
