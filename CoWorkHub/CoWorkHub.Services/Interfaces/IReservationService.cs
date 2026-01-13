using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Interfaces
{
    public interface IReservationService : ICRUDService<Model.Reservation, ReservationSearchObject, ReservationInsertRequest, ReservationUpdateRequest>
    {
        public Model.Reservation Confirm(int id);
        public Model.Reservation Cancel(int id);
        public Model.Reservation Complete(int id);
        public List<string> AllowedActions(int id);
        public ActionResult<bool> HasReviewed(int reservationId);
        public Task HandleReservationStates();
    }
}
