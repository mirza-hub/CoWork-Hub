using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Interfaces
{
    public interface IWorkspaceTypeService : ICRUDService<Model.WorkspaceType, WorkspaceTypeSearchObject, WorkspaceTypeInsertRequest, WorkspaceTypeUpdateRequest>
    { }
}
