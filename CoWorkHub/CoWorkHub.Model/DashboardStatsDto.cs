using System;
using System.Collections.Generic;
using System.Text;

namespace CoWorkHub.Model
{
    public class DashboardStatsDto
    {
        public int TotalReservations { get; set; }
        public int ActiveReservations { get; set; }
        public int CancelledReservations { get; set; }
        public int TotalUsers { get; set; }
        public int TotalWorkingSpaces { get; set; }
        public decimal TotalRevenue { get; set; }
        public Dictionary<string, int>? ReservationsByCity { get; set; }
        public Dictionary<string, int>? ReservationsByWorkspaceType { get; set; }
    }

}
