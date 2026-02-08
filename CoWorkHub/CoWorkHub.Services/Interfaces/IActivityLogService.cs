using CoWorkHub.Model;
using CoWorkHub.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Interfaces
{
    public interface IActivityLogService
    {
        void LogAsync(
        int? userId,
        string action,
        string entity,
        string? description = null);

        public PagedResult<Model.ActivityLog> GetPaged(ActivityLogSearchObject search);
    }
}
