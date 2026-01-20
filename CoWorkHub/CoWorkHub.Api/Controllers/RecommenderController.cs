using CoWorkHub.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace CoWorkHub.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RecommenderController : ControllerBase
    {
        private readonly IRecommenderService _recommenderService;

        public RecommenderController(IRecommenderService recommenderService)
        {
            _recommenderService = recommenderService;
        }

        [HttpGet("recommended-for-user")]
        [Authorize]
        public async Task<IActionResult> GetRecommendedForUser()
        {
            try
            {
                var userIdClaim = User.FindFirst("UserId");

                if (userIdClaim == null)
                {
                    userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier);

                    if (userIdClaim == null)
                    {
                        return Unauthorized(new
                        {
                            Message = "User ID not found in token",
                            AvailableClaims = User.Claims.Select(c => new { c.Type, c.Value })
                        });
                    }
                }

                if (!int.TryParse(userIdClaim.Value, out int userId))
                {
                    return BadRequest(new
                    {
                        Message = "Could not parse User ID",
                        ClaimValue = userIdClaim.Value,
                        ClaimType = userIdClaim.Type
                    });
                }

                var recommendations = await _recommenderService.GetRecommendedSpaces(userId);

                return Ok(new
                {
                    Message = "Personalized recommendations",
                    UserId = userId,
                    Count = recommendations.Count,
                    Recommendations = recommendations
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    Error = "Internal server error",
                    Message = ex.Message,
                    Details = ex.InnerException?.Message
                });
            }
        }

        [HttpGet("recommended-for-user/{userId}")]
        [Authorize(Roles = "Admin")] // Samo admini mogu vidjeti tuđe preporuke
        public async Task<IActionResult> GetRecommendedForUserById(int userId)
        {
            try
            {
                var recommendations = await _recommenderService.GetRecommendedSpaces(userId);
                return Ok(new
                {
                    Message = $"Recommendations for user {userId}",
                    Recommendations = recommendations
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpGet("recommended-for-guest")]
        [AllowAnonymous]
        public async Task<IActionResult> GetRecommendedForGuest()
        {
            try
            {
                var recommendations = await _recommenderService.GetRecommendedSpacesForGuest();
                return Ok(new
                {
                    Message = "Popular spaces for guests",
                    Count = recommendations.Count,
                    Recommendations = recommendations
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Internal server error: {ex.Message}");
            }
        }

        [HttpGet("debug-claims")]
        [Authorize]
        public IActionResult DebugClaims()
        {
            // Helper endpoint za debug
            var claims = User.Claims.Select(c => new
            {
                Type = c.Type,
                Value = c.Value
            }).ToList();

            return Ok(new
            {
                IsAuthenticated = User.Identity?.IsAuthenticated,
                UserName = User.Identity?.Name,
                Claims = claims
            });
        }
    }
}
