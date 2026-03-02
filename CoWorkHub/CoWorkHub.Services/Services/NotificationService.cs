using CoWorkHub.Model;
using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class NotificationService : BaseCRUDService<Model.Notification, NotificationSearchObject, Database.Notification, NotificationInsertRequest, NotificationUpdateRequest>, INotificationService
    {
        private readonly ICurrentUserService _currentUserService;

        public NotificationService(Database._210095Context context, IMapper mapper,
            ICurrentUserService currentUserService) 
            : base(context, mapper)
        { 
            _currentUserService = currentUserService;
        }

        public override IQueryable<Database.Notification> AddFilter(NotificationSearchObject search, IQueryable<Database.Notification> query)
        {
            query = base.AddFilter(search, query);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.IsRead.HasValue)
                query = query.Where(x => x.IsRead == search.IsRead.Value);

            if (search.DateFrom.HasValue)
                query = query.Where(x => x.CreatedAt >= search.DateFrom.Value);

            if (search.DateTo.HasValue)
                query = query.Where(x => x.CreatedAt <= search.DateTo.Value);

            return query;
        }

        public Notification MarkAsRead(int notificationId)
        {
            var notification = Context.Notifications
                .FirstOrDefault(n => n.NotificationId == notificationId && !n.IsDeleted);

            if (notification == null)
                throw new UserException("Notifikacija nije pronađena.");

            notification.IsRead = true;

            Context.SaveChanges();

            return Mapper.Map<Model.Notification>(notification);
        }

        public void MarkAllAsRead()
        {
            var userId = (int)_currentUserService.GetUserId();

            var notifications = Context.Notifications
                .Where(n => n.UserId == userId && !n.IsDeleted && !n.IsRead)
                .ToList();

            if (!notifications.Any())
                return;

            foreach (var notification in notifications)
            {
                notification.IsRead = true;
            }

            Context.SaveChanges();
        }
    }
}
