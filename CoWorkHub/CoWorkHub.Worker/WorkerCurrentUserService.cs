using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Worker
{
    public class WorkerCurrentUserService : ICurrentUserService
    {
        public User? GetCurrentUser()
        {
            return null;
        }

        public string? GetUserEmail()
        {
            return "worker@coworkhub.local";
        }

        public int? GetUserId()
        {
            return -1;
        }

        public string? GetUsername()
        {
            return "Worker";
        }

        public string? GetUserRole()
        {
            return "Worker";
        }
    }
}
