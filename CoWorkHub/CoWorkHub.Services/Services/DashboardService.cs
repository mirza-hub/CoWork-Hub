using CoWorkHub.Model;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class DashboardService : IDashboardService
    {
        private readonly _210095Context _context;

        public DashboardService(_210095Context context)
        {
            _context = context;
        }

        public async Task<DashboardStatsDto> GetDashboardStatsAsync()
        {
            var dto = new DashboardStatsDto
            {
                TotalReservations = await _context.Reservations.CountAsync(r => !r.IsDeleted),
                ActiveReservations = await _context.Reservations.CountAsync(r => !r.IsDeleted && r.CanceledAt == null),
                CancelledReservations = await _context.Reservations.CountAsync(r => !r.IsDeleted && r.CanceledAt != null),
                TotalUsers = await _context.Users.CountAsync(u => !u.IsDeleted),
                TotalWorkingSpaces = await _context.WorkingSpaces.CountAsync(w => !w.IsDeleted),
                TotalRevenue = await _context.Payments
                                             .Where(p => !p.IsDeleted && p.StateMachine == "Paid")
                                             .SumAsync(p => (decimal?)p.TotalPaymentAmount) ?? 0
            };

            // Rezervacije po gradovima
            dto.ReservationsByCity = await _context.Reservations
                .Where(r => !r.IsDeleted && (r.StateMachine == "pending" || r.StateMachine == "confirmed" || r.StateMachine == "completed"))
                .Include(r => r.SpaceUnit)
                .ThenInclude(su => su.WorkingSpace)
                .ThenInclude(ws => ws.City)
                .GroupBy(r => r.SpaceUnit.WorkingSpace.City.CityName)
                .Select(g => new { City = g.Key, Count = g.Count() })
                .ToDictionaryAsync(k => k.City, v => v.Count);

            // Rezervacije po tipu workspace-a
            dto.ReservationsByWorkspaceType = await _context.Reservations
                 .Where(r => !r.IsDeleted && (r.StateMachine == "pending" || r.StateMachine == "confirmed" || r.StateMachine == "completed"))
                .Include(r => r.SpaceUnit)
                .ThenInclude(su => su.WorkspaceType)
                .GroupBy(r => r.SpaceUnit.WorkspaceType.TypeName)
                .Select(g => new { Type = g.Key, Count = g.Count() })
                .ToDictionaryAsync(k => k.Type, v => v.Count);

            return dto;
        }

        public async Task<List<RevenueByMonthDto>> GetRevenueByMonth()
        {
            var query = await _context.Payments
                .Where(p => !p.IsDeleted && p.StateMachine == "paid")
                .GroupBy(p => new { p.PaymentDate.Year, p.PaymentDate.Month })
                .Select(g => new
                {
                    Year = g.Key.Year,
                    Month = g.Key.Month,
                    Revenue = g.Sum(p => p.TotalPaymentAmount)
                })
                .OrderBy(x => x.Year)
                .ThenBy(x => x.Month)
                .ToListAsync();

            var result = query.Select(x => new RevenueByMonthDto
            {
                Month = $"{x.Year}-{x.Month:D2}",
                Revenue = x.Revenue
            }).ToList();

            return result;
        }


    }
}
