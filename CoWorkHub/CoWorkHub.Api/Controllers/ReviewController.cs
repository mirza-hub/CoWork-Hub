using CoWorkHub.Api.Controllers.BaseControllers;
using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ReviewController : BaseCRUDController<Model.Review, ReviewSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {
        public ReviewController(IReviewService service)
           : base(service) { }

        [Authorize(Roles = "Admin,User")]
        public override Review Insert(ReviewInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin,User")]
        public override Review Update(int id, ReviewUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles = "Admin,User")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [AllowAnonymous]
        public override PagedResult<Review> GetList([FromQuery] ReviewSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [AllowAnonymous]
        public override Review GetById(int id)
        {
            return base.GetById(id);
        }
    }
}
