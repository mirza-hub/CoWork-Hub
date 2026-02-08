using CoWorkHub.Model;
using CoWorkHub.Model.Recommender;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;
using Microsoft.ML.Data;
using Microsoft.ML.Trainers;

namespace CoWorkHub.Services.Services.Recommender
{
    public class RecommenderService : IRecommenderService
    {
        private readonly _210095Context _context;
        private readonly MLContext _mlContext;
        private PredictionEngine<SpaceUnitData, SpaceUnitPrediction> _predictionEngine;
        private readonly ILogger<RecommenderService> _logger;

        public RecommenderService(_210095Context context, ILogger<RecommenderService> logger)
        {
            _context = context;
            _logger = logger;
            _mlContext = new MLContext();
            InitializeModel();
        }

        private void InitializeModel()
        {
            try
            {
                // Učitaj sve dostupne space unit-ove
                var allSpaces = _context.SpaceUnits
                    .Include(su => su.WorkspaceType)
                    .Include(su => su.WorkingSpace)
                        .ThenInclude(ws => ws.City)
                    .Include(su => su.SpaceUnitResources)
                        .ThenInclude(sur => sur.Resources)
                    .Include(su => su.Reservations)
                        .ThenInclude(r => r.Review)
                    .Where(su => !su.IsDeleted && su.StateMachine == "Active")
                    .ToList();

                var allSpaceData = allSpaces.Select(s => new SpaceUnitData
                {
                    SpaceUnitId = s.SpaceUnitId,
                    Name = s.Name,
                    Description = s.Description ?? "",
                    WorkspaceType = s.WorkspaceType?.TypeName ?? "",
                    Capacity = s.Capacity,
                    PricePerDay = (float)s.PricePerDay,
                    City = s.WorkingSpace?.City?.CityName ?? "",
                    Resources = string.Join(", ", s.SpaceUnitResources
                        .Where(sur => !sur.IsDeleted)
                        .Select(sur => sur.Resources?.ResourceName ?? "")),
                    AverageRating = (float)(s.Reservations
                        .Where(r => r.Review != null && !r.Review.IsDeleted)
                        .Select(r => (double?)r.Review.Rating)
                        .Average() ?? 0)
                }).ToList();

                // Kreiranje ML pipeline
                var pipeline = _mlContext.Transforms.Categorical.OneHotEncoding(
                        outputColumnName: "WorkspaceTypeEncoded",
                        inputColumnName: nameof(SpaceUnitData.WorkspaceType))
                    .Append(_mlContext.Transforms.Categorical.OneHotEncoding(
                        outputColumnName: "CityEncoded",
                        inputColumnName: nameof(SpaceUnitData.City)))
                    .Append(_mlContext.Transforms.Text.FeaturizeText(
                        outputColumnName: "ResourcesFeaturized",
                        inputColumnName: nameof(SpaceUnitData.Resources)))
                    .Append(_mlContext.Transforms.Text.FeaturizeText(
                        outputColumnName: "DescriptionFeaturized",
                        inputColumnName: nameof(SpaceUnitData.Description)))
                    .Append(_mlContext.Transforms.Concatenate(
                        outputColumnName: "Features",
                        "WorkspaceTypeEncoded",
                        "CityEncoded",
                        "ResourcesFeaturized",
                        "DescriptionFeaturized"));

                var model = pipeline.Fit(_mlContext.Data.LoadFromEnumerable(allSpaceData));
                _predictionEngine = _mlContext.Model.CreatePredictionEngine<SpaceUnitData, SpaceUnitPrediction>(model);

                _logger.LogInformation("Recommender model initialized successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to initialize recommender model");
                throw;
            }
        }


        public async Task<List<SpaceUnitPrediction>> GetRecommendedSpaces(int userId)
        {
            try
            {
                var userReservationIds = await _context.Reservations
                    .Where(r => r.UsersId == userId && !r.IsDeleted)
                    .Select(r => r.SpaceUnitId)
                    .Distinct()
                    .ToListAsync();

                if (!userReservationIds.Any())
                {
                    return await GetPopularSpaces();
                }

                // 2. Dohvati space unit-ove koje je korisnik rezervisao
                var userSpaces = await _context.SpaceUnits
                    .Include(su => su.WorkspaceType)
                    .Include(su => su.WorkingSpace)
                        .ThenInclude(ws => ws.City)
                    .Include(su => su.SpaceUnitResources)
                        .ThenInclude(sur => sur.Resources)
                    .Include(su => su.Reservations)
                        .ThenInclude(r => r.Review)
                    .Where(su => userReservationIds.Contains(su.SpaceUnitId) && !su.IsDeleted)
                    .ToListAsync();

                var userSpaceData = userSpaces.Select(s => new SpaceUnitData
                {
                    SpaceUnitId = s.SpaceUnitId,
                    Name = s.Name,
                    Description = s.Description,
                    WorkspaceType = s.WorkspaceType?.TypeName ?? "",
                    Capacity = s.Capacity,
                    PricePerDay = (float)s.PricePerDay,
                    City = s.WorkingSpace?.City?.CityName ?? "",
                    Resources = string.Join(", ", s.SpaceUnitResources
                        .Where(sur => !sur.IsDeleted)
                        .Select(sur => sur.Resources?.ResourceName ?? "")),
                    AverageRating = (float)(s.Reservations
                        .Where(r => r.Review != null && !r.Review.IsDeleted)
                        .Select(r => (double?)r.Review.Rating)
                        .Average() ?? 0.0)
                }).ToList();

                // 3. Dohvati sve dostupne space unit-ove koje korisnik NIJE rezervisao
                var allAvailableSpaces = await _context.SpaceUnits
                    .Include(su => su.WorkspaceType)
                    .Include(su => su.WorkingSpace)
                        .ThenInclude(ws => ws.City)
                    .Include(su => su.SpaceUnitResources)
                        .ThenInclude(sur => sur.Resources)
                    .Include(su => su.Reservations)
                        .ThenInclude(r => r.Review)
                    .Where(su => !userReservationIds.Contains(su.SpaceUnitId) &&
                                 !su.IsDeleted &&
                                 su.StateMachine == "Active")
                    .ToListAsync();

                var allSpaceData = allAvailableSpaces.Select(s => new SpaceUnitData
                {
                    SpaceUnitId = s.SpaceUnitId,
                    Name = s.Name,
                    Description = s.Description,
                    WorkspaceType = s.WorkspaceType?.TypeName ?? "",
                    Capacity = s.Capacity,
                    PricePerDay = (float)s.PricePerDay,
                    City = s.WorkingSpace?.City?.CityName ?? "",
                    Resources = string.Join(", ", s.SpaceUnitResources
                        .Where(sur => !sur.IsDeleted)
                        .Select(sur => sur.Resources?.ResourceName ?? "")),
                    AverageRating = (float)(s.Reservations
                        .Where(r => r.Review != null && !r.Review.IsDeleted)
                        .Select(r => (double?)r.Review.Rating)
                        .Average() ?? 0.0)
                }).ToList();

                // 4. Izračunaj sličnost
                var predictions = new List<SpaceUnitPrediction>();

                foreach (var space in allSpaceData)
                {
                    float totalScore = 0;
                    foreach (var userSpace in userSpaceData)
                    {
                        var spaceVector = _predictionEngine.Predict(space).Features;
                        var userVector = _predictionEngine.Predict(userSpace).Features;
                        totalScore += CalculateCosineSimilarity(spaceVector, userVector);
                    }

                    predictions.Add(new SpaceUnitPrediction
                    {
                        SpaceUnitId = space.SpaceUnitId,
                        Score = userSpaceData.Count > 0 ? totalScore / userSpaceData.Count : 0,
                        Name = space.Name,
                        PricePerDay = space.PricePerDay
                    });
                }

                // 5. Vrati top 5 preporuka
                return predictions
                    .OrderByDescending(p => p.Score)
                    .Take(5)
                    .ToList();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting recommendations for user {UserId}", userId);
                return await GetPopularSpaces(); // Fallback na popularne
            }
        }

        public async Task<List<SpaceUnitPrediction>> GetRecommendedSpacesForGuest()
        {
            return await GetPopularSpaces();
        }

        private async Task<List<SpaceUnitPrediction>> GetPopularSpaces()
        {
            // Vrati najpopularnije prostore (najviše rezervacija ili najbolje ocjene)
            var popularSpaces = await _context.SpaceUnits
                .Include(su => su.Reservations)
                .Include(su => su.Reservations)
                    .ThenInclude(r => r.Review)
                .Where(su => !su.IsDeleted && su.StateMachine == "Active")
                .OrderByDescending(su => su.Reservations.Count(r => !r.IsDeleted))
                .ThenByDescending(su => su.Reservations
                    .Where(r => r.Review != null && !r.Review.IsDeleted)
                    .Average(r => (double?)r.Review.Rating) ?? 0)
                .Take(5)
                .Select(su => new SpaceUnitPrediction
                {
                    SpaceUnitId = su.SpaceUnitId,
                    Name = su.Name,
                    PricePerDay = (float)su.PricePerDay,
                    Score = 0.5f // Default score za popularne
                })
                .ToListAsync();

            return popularSpaces;
        }

        private static float CalculateCosineSimilarity(float[] vectorA, float[] vectorB)
        {
            if (vectorA == null || vectorB == null || vectorA.Length != vectorB.Length)
                return 0;

            float dotProduct = 0, magnitudeA = 0, magnitudeB = 0;
            for (int i = 0; i < vectorA.Length; i++)
            {
                dotProduct += vectorA[i] * vectorB[i];
                magnitudeA += vectorA[i] * vectorA[i];
                magnitudeB += vectorB[i] * vectorB[i];
            }

            magnitudeA = (float)Math.Sqrt(magnitudeA);
            magnitudeB = (float)Math.Sqrt(magnitudeB);

            return magnitudeA > 0 && magnitudeB > 0 ?
                   dotProduct / (magnitudeA * magnitudeB) : 0;
        }

        public async Task<PagedResult<SpaceUnitRecommendationDTO>> GetRecommendedSpacesPaged(int userId, BaseSearchObject search)
        {
            var predictions = await GetRecommendedSpaces(userId);

            var spaceIds = predictions.Select(p => p.SpaceUnitId).ToList();

            var query = _context.SpaceUnits
                .Include(su => su.WorkspaceType)
                .Include(su => su.WorkingSpace)
                    .ThenInclude(ws => ws.City)
                .Include(su => su.SpaceUnitResources)
                    .ThenInclude(sur => sur.Resources)
                .Include(su => su.SpaceUnitImages)
                .Include(su => su.Reservations)
                    .ThenInclude(r => r.Review)
                .Where(su => spaceIds.Contains(su.SpaceUnitId) && !su.IsDeleted);

            // Apliciraj filtere iz search objekta
            if (!string.IsNullOrEmpty(search?.OrderBy))
            {
                // Dodaj sortiranje po potrebi
            }

            var page = search?.Page ?? 1;
            var pageSize = search?.PageSize ?? 10;

            var totalCount = await query.CountAsync();
            var spaces = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            var result = spaces.Select(s => new SpaceUnitRecommendationDTO
            {
                SpaceUnitId = s.SpaceUnitId,
                Name = s.Name,
                Description = s.Description,
                PricePerDay = s.PricePerDay,
                WorkspaceType = s.WorkspaceType?.TypeName,
                City = s.WorkingSpace?.City?.CityName,
                Capacity = s.Capacity,
                Resources = s.SpaceUnitResources
                    .Where(sur => !sur.IsDeleted)
                    .Select(sur => sur.Resources?.ResourceName)
                    .Where(r => !string.IsNullOrEmpty(r))
                    .ToList(),
                AverageRating = s.Reservations
                    .Where(r => r.Review != null && !r.Review.IsDeleted)
                    .Select(r => (double?)r.Review.Rating)
                    .Average(),
                RecommendationScore = predictions.FirstOrDefault(p => p.SpaceUnitId == s.SpaceUnitId)?.Score ?? 0,
                ImageUrl = s.SpaceUnitImages.FirstOrDefault()?.ImagePath
            }).ToList();

            return new PagedResult<SpaceUnitRecommendationDTO>
            {
                ResultList = result,
                Count = totalCount,
                Page = page,
                PageSize = pageSize,
                TotalPages = (int)Math.Ceiling(totalCount / (double)pageSize)
            };
        }
    }
}
