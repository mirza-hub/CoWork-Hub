using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Interfaces
{
    public interface IWorkingSpaceService : ICRUDService<WorkingSpace, WorkingSpaceSearchObject, WorkingSpaceInsertRequest, WorkingSpaceUpdateRequest>
    {
    }
}
