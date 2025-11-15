using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class WorkspaceType
    {
        public int WorkspaceTypeId { get; set; }
        public string TypeName { get; set; } = null!;
        public bool IsDeleted { get; set; } = false;
    }
}
