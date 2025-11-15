using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model.Requests
{
    public class ReviewUpdateRequest
    {
        public byte? Rating { get; set; }
        public string? Comment { get; set; }
    }
}
