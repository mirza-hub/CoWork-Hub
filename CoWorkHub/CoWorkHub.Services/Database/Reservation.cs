using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class Reservation : ISoftDeletable
{
    public int ReservationId { get; set; }

    public int SpaceUnitId { get; set; }
    
    public int UsersId { get; set; }

    //public int WorkingSpacesId { get; set; }

    public DateTime StartDate { get; set; }

    public DateTime EndDate { get; set; }

    public int PeopleCount { get; set; } = 1;

    public decimal TotalPrice { get; set; }

    public string StateMachine { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime? CanceledAt { get; set; }

    public virtual ICollection<Payment> Payments { get; set; } = new List<Payment>();

    public virtual User Users { get; set; } = null!;

    //public virtual WorkingSpace WorkingSpaces { get; set; } = null!;

    public virtual SpaceUnit SpaceUnit { get; set; } = null!;

    public DateTime? DeletedAt { get; set; }

    public bool IsDeleted { get; set; } = false;
}
