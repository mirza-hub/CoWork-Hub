using CoWorkHub.Services.Database;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Http;
using System.Security.Claims;

namespace CoWorkHub.Services.Auth
{
    public class CurrentUserService : ICurrentUserService
    {
        public readonly IHttpContextAccessor _httpContextAccessor;
        private readonly _210095Context _context;

        public CurrentUserService(IHttpContextAccessor httpContextAccessor, _210095Context context)
        {
            _httpContextAccessor = httpContextAccessor;
            _context = context;
        }

        public int? GetUserId()
        {
            var userPrincipal = _httpContextAccessor.HttpContext?.User;

            var username = _httpContextAccessor.HttpContext?.User?.Claims
                 .FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;

            if (string.IsNullOrEmpty(username))
                return null;

            var user = _context.Users.FirstOrDefault(u => u.Username == username);

            return user?.UsersId;
        }

        public string? GetUsername()
        {
            var userPrincipal = _httpContextAccessor.HttpContext?.User;
            return userPrincipal?.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
        }

        public string? GetUserEmail()
        {
            var username = GetUsername();
            if (username == null) return null;

            var user = _context.Users.FirstOrDefault(u => u.Username == username);
            return user?.Email;
        }

        public string? GetUserRole()
        {
            var userPrincipal = _httpContextAccessor.HttpContext?.User;
            return userPrincipal?.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)?.Value;
        }

        public User? GetCurrentUser()
        {
            var username = GetUsername();

            if (username == null)
                return null;

            return _context.Users
                .Include(u => u.UserRoles)
                .ThenInclude(ur => ur.Role)
                .FirstOrDefault(u => u.Username == username);
        }
    }
}
