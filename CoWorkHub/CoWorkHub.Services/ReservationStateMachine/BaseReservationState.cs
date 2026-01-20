using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Services.Database;
using MapsterMapper;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.ReservationStateMachine
{
    public class BaseReservationState
    {
        public _210095Context Context { get; set; }
        public IMapper Mapper { get; set; }
        public IServiceProvider ServiceProvider { get; set; }
        
        public BaseReservationState(_210095Context context, IMapper mapper, IServiceProvider serviceProvider)
        {
            Context = context;
            Mapper = mapper;
            ServiceProvider = serviceProvider;
        }

        public virtual Model.Reservation Insert(ReservationInsertRequest request)
        {
            throw new UserException("Metoda nije dozvoljena.");
        }

        public virtual Model.Reservation Update(int id, ReservationUpdateRequest request)
        {
            throw new UserException("Metoda nije dozvoljena.");
        }

        public virtual Model.Reservation Confirm(int id)
        {
            throw new UserException("Metoda nije dozvoljena.");
        }

        public virtual Model.Reservation Cancel(int id)
        {
            throw new UserException("Metoda nije dozvoljena.");
        }

        public virtual Model.Reservation Complete(int id)
        {
            throw new UserException("Metoda nije dozvoljena.");
        }

        public virtual List<string> AllowedActions(Database.Reservation entity)
        {
            throw new UserException("Metoda nije dozvoljena.");
        }

        public BaseReservationState CreateState(string stateName)
        {
            switch (stateName)
            {
                case "initial":
                    return ServiceProvider.GetService<InitialReservationState>();
                case "pending":
                    return ServiceProvider.GetService<PendingReservationState>();
                case "confirmed":
                    return ServiceProvider.GetService<ConfirmedReservationState>();
                case "canceled":
                    return ServiceProvider.GetService<CanceledReservationiState>();
                case "completed":
                    return ServiceProvider.GetService<CompletedReservationiState>();
                default: throw new UserException("State nije prepoznat");
            }
        }
    }
}
