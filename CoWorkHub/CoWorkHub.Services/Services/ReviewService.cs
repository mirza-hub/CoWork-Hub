using CoWorkHub.Model;
using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Scaffolding.Metadata;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class ReviewService : BaseCRUDService<Model.Review, ReviewSearchObject, Database.Review, ReviewInsertRequest, ReviewUpdateRequest>, IReviewService
    {
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;

        public ReviewService(_210095Context context, 
            IMapper mapper,
            ICurrentUserService currentUserService,
            IActivityLogService activityLogService) 
            : base(context, mapper)
        {
            _currentUserService = currentUserService;
            _activityLogService = activityLogService;
        }

        public override IQueryable<Database.Review> AddFilter(ReviewSearchObject search, IQueryable<Database.Review> query)
        {
            query = base.AddFilter(search, query);

            if (search.ReservationId.HasValue)
                query = query.Where(r => r.ReservationId == search.ReservationId.Value);

            if (search.SpaceUnitId.HasValue)
                query = query.Where(r => r.Reservation.SpaceUnitId == search.SpaceUnitId.Value);

            if (search.RatingFrom.HasValue)
                query = query.Where(x => x.Rating >= search.RatingFrom.Value);

            if (search.RatingTo.HasValue)
                query = query.Where(x => x.Rating <= search.RatingTo.Value);

            if (search.CreatedFrom.HasValue)
                query = query.Where(x => x.CreatedAt >= search.CreatedFrom.Value);

            if (search.CreatedTo.HasValue)
                query = query.Where(x => x.CreatedAt <= search.CreatedTo.Value);

            if (search.IncludeReservation)
                query = query.Include(r => r.Reservation).ThenInclude(r=>r.Users);

            if (search.IncludeReservationSpaceUnit)
                query = query
                    .Include(r => r.Reservation)
                    .ThenInclude(res => res.SpaceUnit);

            return query;
        }

        public override void BeforeInsert(ReviewInsertRequest request, Database.Review entity)
        {
            base.BeforeInsert(request, entity);

            // 1. Rating mora biti izmedju 1 i 5
            if (request.Rating < 1 || request.Rating > 5)
                throw new UserException("Ocjena mora biti između 1 i 5.");

            // 2. Komentar ne smije biti prazan
            if (string.IsNullOrWhiteSpace(request.Comment))
                throw new UserException("Komentar je obavezan.");

            int userId = (int)_currentUserService.GetUserId();

            // 3. User smije ostaviti samo jednu recenziju za istu Rezervaciju
            bool alreadyReviewed = Context.Set<Database.Review>().Any(r =>
                r.ReservationId == request.ReservationId &&
                !r.IsDeleted);

            if (alreadyReviewed)
                throw new UserException("Već ste ocijenili ovu rezervaciju.");

            // 4. User mora imati zavrsenu rezervaciju (completed)
            var reservation = Context.Set<Database.Reservation>()
                .FirstOrDefault(r =>
                r.ReservationId == request.ReservationId &&
                r.UsersId == userId &&
                r.EndDate < DateTime.Now &&
                r.StateMachine == "completed" &&
                !r.IsDeleted);

            if (reservation == null)
                throw new UserException("Moguće je ocijeniti samo završene rezervacije.");

            entity.CreatedAt = DateTime.UtcNow;
        }

        public override void BeforeUpdate(ReviewUpdateRequest request, Database.Review entity)
        {
            base.BeforeUpdate(request, entity);

            if (entity == null || entity.IsDeleted)
                throw new UserException("Recenzija nije pronađena.");

            // 2. User može update-ati samo svoj review
            int loggedUserId = (int)_currentUserService.GetUserId();
            var reservation = Context.Set<Database.Reservation>()
                .FirstOrDefault(r =>
                r.ReservationId == entity.ReservationId &&
                !r.IsDeleted);

            if (reservation.UsersId != loggedUserId)
                throw new UserException("Nije moguće urediti ovu rezervaciju.");

            // 3. Validacija ratinga
            if (request.Rating.HasValue && (request.Rating < 1 || request.Rating > 5))
                throw new UserException("Ocjena mora biti između 1 i 5.");

            // 4. Validacija komentara
            if (request.Comment != null && string.IsNullOrWhiteSpace(request.Comment))
                throw new UserException("Komentar ne može biti prazan.");

            // 5. Update vremena
            entity.ModifiedAt = DateTime.Now;
        }

        public override void BeforeDelete(Database.Review entity)
        {
            base.BeforeDelete(entity);

            entity.DeletedBy = _currentUserService.GetUserId();
        }

        public override void AfterInsert(ReviewInsertRequest request, Database.Review entity)
        {
            base.AfterInsert(request, entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CREATE",
            "Review",
            $"Kreirana recenzija {entity.ReviewsId} za rezervaciju {entity.ReservationId}");
        }

        public override void AfterUpdate(ReviewUpdateRequest request, Database.Review entity)
        {
            base.AfterUpdate(request, entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "UPDATE",
            "Review",
            $"Kreirana recenzija {entity.ReviewsId} za rezervaciju {entity.ReservationId}");
        }

        public override void AfterDelete(Database.Review entity)
        {
            base.AfterDelete(entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "DELETE",
            "Review",
            $"Kreirana recenzija  {entity.ReviewsId}  za rezervaciju {entity.ReservationId}");
        }
    }
}
