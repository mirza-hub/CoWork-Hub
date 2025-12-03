using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class SpaceUnitImage
    {
        public int ImageId { get; set; }
        public int SpaceUnitId { get; set; }
        public string ImagePath { get; set; } = null!;
        public bool IsDeleted { get; set; } = false;
    }
}
