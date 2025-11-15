using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class Reservation
    {
        public int ReservationId { get; set; }
        public int SpaceUnitId { get; set; }
        public int UsersId { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int PeopleCount { get; set; } = 1;
        public decimal TotalPrice { get; set; }
        public string StateMachine { get; set; }
        public virtual User Users { get; set; } = null!;
        public virtual SpaceUnit SpaceUnit { get; set; } = null!;
        public bool IsDeleted { get; set; } = false;
    }
}
