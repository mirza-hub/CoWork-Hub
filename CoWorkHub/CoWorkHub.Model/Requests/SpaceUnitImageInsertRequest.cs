using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class SpaceUnitImageInsertRequest
    {
        public int SpaceUnitId { get; set; }
        public List<string> Base64Images { get; set; } = new List<string>();
        public string? Description { get; set; }
    }
}
