using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;

namespace CoWorkHub.Services.Database;

public partial class Payment : ISoftDeletable
{
    public int PaymentId { get; set; }

    public int ReservationId { get; set; }

    public int PaymentMethodId { get; set; }

    public DateTime PaymentDate { get; set; }

    public decimal? Discount { get; set; }

    public decimal TotalPaymentAmount { get; set; }

    public int Status { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public DateTime? DeletedAt { get; set; }

    public virtual PaymentMethod PaymentMethod { get; set; } = null!;

    public virtual Reservation Reservation { get; set; } = null!;

    public bool IsDeleted { get; set; } = false;
}
