using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Auth
{
    public interface ICurrentUserService
    {
        int? GetUserId();
        string? GetUsername();
        string? GetUserEmail();
        string? GetUserRole();
        Database.User? GetCurrentUser();
    }
}
