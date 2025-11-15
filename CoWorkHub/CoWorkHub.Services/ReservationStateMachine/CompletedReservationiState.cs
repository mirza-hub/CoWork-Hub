using CoWorkHub.Services.Database;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.ReservationStateMachine
{
    public class CompletedReservationiState : BaseReservationState
    {
        public CompletedReservationiState(_210095Context context, IMapper mapper, IServiceProvider serviceProvider)
           : base(context, mapper, serviceProvider)
        { }
    }
}
