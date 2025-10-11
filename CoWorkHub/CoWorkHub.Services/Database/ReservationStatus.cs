﻿using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class ReservationStatus
{
    public int ReservationStatusId { get; set; }

    public string StatusName { get; set; } = null!;

    public DateTime CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public DateTime? DeletedAt { get; set; }

    public virtual ICollection<Reservation> Reservations { get; set; } = new List<Reservation>();
}
