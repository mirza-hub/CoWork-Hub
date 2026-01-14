using CoWorkHub.Model;
using CoWorkHub.Model.Recommender;
using CoWorkHub.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Interfaces
{
    public interface IRecommenderService
    {
        Task<List<SpaceUnitPrediction>> GetRecommendedSpaces(int userId);
        Task<List<SpaceUnitPrediction>> GetRecommendedSpacesForGuest();
        Task<PagedResult<SpaceUnitRecommendationDTO>> GetRecommendedSpacesPaged(int userId, BaseSearchObject search);
    }
}
