using CoWorkHub.Services.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class GeoLocationService : IGeoLocationService
    {
        private readonly HttpClient _http;

        public GeoLocationService(HttpClient http)
        {
            _http = http;
            _http.DefaultRequestHeaders.UserAgent.ParseAdd("CoWorkHub/1.0");
        }

        public async Task<(double lat, double lon)> GetCoordinatesAsync(string cityName)
        {
            if (string.IsNullOrWhiteSpace(cityName))
                throw new ArgumentException("City name cannot be empty");

            // Encode za URL (razmaci, dijakritika)
            var url = $"https://nominatim.openstreetmap.org/search?format=json&q={Uri.EscapeDataString(cityName)}";

            var request = new HttpRequestMessage(HttpMethod.Get, url);
            // Nominatim zahtijeva User-Agent
            request.Headers.Add("User-Agent", "CoWorkHubApp/1.0");

            var response = await _http.SendAsync(request);
            response.EnsureSuccessStatusCode();

            var json = await response.Content.ReadAsStringAsync();

            // Deserialize u listu
            var result = JsonSerializer.Deserialize<List<NominatimResult>>(json);

            if (result == null || result.Count == 0)
                throw new Exception($"Coordinates not found for city: {cityName}");

            // Parsiranje lat/lon
            if (!double.TryParse(result[0].Lat, out double lat))
                throw new Exception($"Invalid latitude returned for city: {cityName}");
            if (!double.TryParse(result[0].Lon, out double lon))
                throw new Exception($"Invalid longitude returned for city: {cityName}");

            return (lat, lon);
        }
        private class NominatimResult
        {
            [JsonPropertyName("lat")]
            public string Lat { get; set; } = null!;

            [JsonPropertyName("lon")]
            public string Lon { get; set; } = null!;
        }
    }
}
