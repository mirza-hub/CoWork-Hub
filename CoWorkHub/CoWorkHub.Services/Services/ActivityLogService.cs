using CoWorkHub.Model;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class ActivityLogService : IActivityLogService
    {
        private readonly _210095Context _context;
        public IMapper _mapper { get; set; }

        public ActivityLogService(_210095Context context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public void LogAsync(
            int? userId,
            string action,
            string entity,
            string? description = null)
        {
            try
            {
                var log = new Database.ActivityLog
                {
                    UserId = userId,
                    Action = action,
                    Entity = entity,
                    Description = description,
                    CreatedAt = DateTime.UtcNow
                };

                _context.ActivityLogs.Add(log);
                _context.SaveChanges();
            }
            catch
            {
            }
        }

        public PagedResult<Model.ActivityLog> GetPaged(ActivityLogSearchObject search)
        {
            List<Model.ActivityLog> result = new List<Model.ActivityLog>();

            var query = _context.ActivityLogs.AsQueryable();

            query = query.Include(x => x.User);

            if (!string.IsNullOrEmpty(search.Action))
            {
                var actionOrUser = search.Action.ToLower();
                query = query.Where(x => x.User != null &&
                     (x.User.FirstName + " " + x.User.LastName).ToLower().Contains(actionOrUser)
                );
            }


            if (!string.IsNullOrEmpty(search.Entity))
                query = query.Where(x => x.Entity.Contains(search.Entity));

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.From.HasValue)
                query = query.Where(x => x.CreatedAt >= search.From.Value);

            if (search.To.HasValue)
                query = query.Where(x => x.CreatedAt <= search.To.Value);

            int count = query.Count();

                // sortiranje
                if (string.IsNullOrEmpty(search.OrderBy))
                {
                    query = query.OrderByDescending(x => x.CreatedAt);
                }
                else
                {
                var entityType = typeof(Database.ActivityLog);
                var property = entityType.GetProperty(search.OrderBy);
                if (property != null)
                {
                    var parameter = Expression.Parameter(entityType, "x");
                    var propertyAccess = Expression.MakeMemberAccess(parameter, property);
                    var orderByExpression = Expression.Lambda(propertyAccess, parameter);

                    string methodName = search.SortDirection.ToLower() switch
                    {
                        "desc" or "descending" => "OrderByDescending",
                        "asc" or "ascending" => "OrderBy",
                        _ => ""
                    };

                    if (!string.IsNullOrEmpty(methodName))
                    {
                        var resultExpression = Expression.Call(
                            typeof(Queryable),
                            methodName,
                            new Type[] { entityType, property.PropertyType },
                            query.Expression,
                            Expression.Quote(orderByExpression)
                        );

                        query = query.Provider.CreateQuery<Database.ActivityLog>(resultExpression);
                    }
                }
            }

            // paginacija
            var page = search?.Page ?? 1;
            var pageSize = search?.PageSize ?? 10;

            if (search?.RetrieveAll != true)
                query = query.Skip((page - 1) * pageSize).Take(pageSize);

            var list = query.ToList();
            result = _mapper.Map(list, result);

            return new PagedResult<Model.ActivityLog>
            {
                ResultList = result,
                Count = count,
                Page = page,
                PageSize = pageSize,
                TotalPages = (int)Math.Ceiling(count / (double)pageSize),
                HasPreviousPage = page > 1,
                HasNextPage = page < (int)Math.Ceiling(count / (double)pageSize)
            };
        }
    }   
}
