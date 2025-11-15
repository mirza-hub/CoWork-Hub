using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.SearchObjects
{
    public class WorkspaceTypeSearchObject : BaseSearchObject
    {
        public string? TypeNameGTE { get; set; } = null!;
    }
}
