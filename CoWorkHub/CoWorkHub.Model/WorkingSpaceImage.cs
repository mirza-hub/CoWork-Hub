using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class WorkingSpaceImage
    {
        public int ImageId { get; set; }
        public int WorkingSpacesId { get; set; }
        public string ImagePath { get; set; } = null!;
        public bool IsDeleted { get; set; } = false;
    }
}
