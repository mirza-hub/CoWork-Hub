using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using Microsoft.EntityFrameworkCore;
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

        public ReviewService(_210095Context context, 
            IMapper mapper,
            ICurrentUserService currentUserService) 
            : base(context, mapper)
        {
            _currentUserService = currentUserService;
        }

        public override IQueryable<Review> AddFilter(ReviewSearchObject search, IQueryable<Review> query)
        {
            query = base.AddFilter(search, query);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UsersId == search.UserId.Value);

            if (search.SpaceUnitId.HasValue)
                query = query.Where(x => x.SpaceUnitId == search.SpaceUnitId.Value);

            if (search.RatingFrom.HasValue)
                query = query.Where(x => x.Rating >= search.RatingFrom.Value);

            if (search.RatingTo.HasValue)
                query = query.Where(x => x.Rating <= search.RatingTo.Value);

            if (search.CreatedFrom.HasValue)
                query = query.Where(x => x.CreatedAt >= search.CreatedFrom.Value);

            if (search.CreatedTo.HasValue)
                query = query.Where(x => x.CreatedAt <= search.CreatedTo.Value);

            if (search.IncludeUser)
                query = query.Include(x => x.Users);

            if (search.IncludeSpaceUnit)
                query = query.Include(x => x.SpaceUnit);

            return query;
        }

        public override void BeforeInsert(ReviewInsertRequest request, Review entity)
        {
            base.BeforeInsert(request, entity);

            // 1. Rating mora biti izmedju 1 i 5
            if (request.Rating < 1 || request.Rating > 5)
                throw new Exception("Rating must be between 1 and 5.");

            // 2. Komentar ne smije biti prazan
            if (string.IsNullOrWhiteSpace(request.Comment))
                throw new Exception("Comment is required.");

            // 3. User smije ostaviti samo jednu recenziju za isti SpaceUnit
            bool alreadyReviewed = Context.Set<Review>().Any(r =>
                r.UsersId == request.UsersId &&
                r.SpaceUnitId == request.SpaceUnitId &&
                !r.IsDeleted);

            if (alreadyReviewed)
                throw new Exception("You have already reviewed this space.");

            // 4. User mora imati zavrsenu rezervaciju (completed)
            bool hasCompletedReservation = Context.Set<Reservation>().Any(r =>
                r.UsersId == request.UsersId &&
                r.SpaceUnitId == request.SpaceUnitId &&
                r.EndDate < DateTime.Now &&
                r.StateMachine == "completed" &&
                !r.IsDeleted);

            if (!hasCompletedReservation)
                throw new Exception("You can only review spaces you have previously used.");

            entity.CreatedAt = DateTime.UtcNow;
        }

        public override void BeforeUpdate(ReviewUpdateRequest request, Review entity)
        {
            base.BeforeUpdate(request, entity);

            if (entity == null || entity.IsDeleted)
                throw new Exception("Review not found.");

            // 2. User može update-ati samo svoj review
            // request.UsersId ne treba i ne smije se koristiti!
            int loggedUserId = (int)_currentUserService.GetUserId(); // ili kako već dohvaćaš usera
            if (entity.UsersId != loggedUserId)
                throw new Exception("You are not allowed to edit this review.");

            // 3. Validacija ratinga
            if (request.Rating.HasValue && (request.Rating < 1 || request.Rating > 5))
                throw new Exception("Rating must be between 1 and 5.");

            // 4. Validacija komentara
            if (request.Comment != null && string.IsNullOrWhiteSpace(request.Comment))
                throw new Exception("Comment cannot be empty.");

            // 5. Update vremena
            entity.ModifiedAt = DateTime.Now;
        }
    }
}
