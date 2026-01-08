using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class WorkingSpaceImageInsertRequest
    {
        public int WorkingSpacesId { get; set; }
        public List<string> Base64Images { get; set; } = new List<string>();
        public string? Description { get; set; }
    }
}
