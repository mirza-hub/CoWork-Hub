using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class ReviewInsertRequest
    {
        public int UsersId { get; set; }
        public int SpaceUnitId { get; set; }
        public byte Rating { get; set; }
        public string Comment { get; set; } = null!;
    }
}
