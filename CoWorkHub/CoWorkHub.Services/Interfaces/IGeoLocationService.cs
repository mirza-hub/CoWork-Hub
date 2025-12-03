using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Interfaces
{
    public interface IGeoLocationService
    {
        Task<(double lat, double lon)> GetCoordinatesAsync(string cityName);
    }
}
