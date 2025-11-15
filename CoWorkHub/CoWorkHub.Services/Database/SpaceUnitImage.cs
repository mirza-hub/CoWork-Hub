using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Database
{
    public partial class SpaceUnitImage : ISoftDeletable
    {
        public int ImageId { get; set; }

        public int SpaceUnitId { get; set; }

        public string ImagePath { get; set; } = null!;

        public string? Description { get; set; }

        public DateTime CreatedAt { get; set; }

        public virtual SpaceUnit SpaceUnit { get; set; } = null!;

        public DateTime? DeletedAt { get; set; }

        public bool IsDeleted { get; set; } = false;
    }
}
