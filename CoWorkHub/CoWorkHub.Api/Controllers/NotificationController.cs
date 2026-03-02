using CoWorkHub.Api.Controllers.BaseControllers;
using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;
using CoWorkHub.Services.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class NotificationController : BaseCRUDController<Model.Notification, NotificationSearchObject, NotificationInsertRequest, NotificationUpdateRequest>
    {
        public NotificationController(INotificationService service) : base(service)
        { }

        [Authorize]
        [HttpPut("{id}/read")]
        public virtual Model.Notification MarkAsRead(int id)
        {
            return (_service as INotificationService).MarkAsRead(id);
        }

        [Authorize]
        [HttpPut("mark-all-as-read")]
        public void MarkAllAsRead()
        {
            (_service as INotificationService).MarkAllAsRead();
        }
    }
}
