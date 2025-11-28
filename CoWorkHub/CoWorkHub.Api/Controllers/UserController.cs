using CoWorkHub.Api.Controllers.BaseControllers;
using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace CoWorkHub.Api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<Model.User, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        public UserController(IUserService service) : base(service)
        { }

        [AllowAnonymous]
        [HttpPost("login")]
        public User Login(string username, string password)
        {
            return (_service as IUserService).Login(username, password);
        }

        [AllowAnonymous]
        public override User Insert(UserInsertRequest request)
        {
            return base.Insert(request);
        }

        [Authorize(Roles = "Admin,User")]
        public override User Update(int id, UserUpdateRequest request)
        {
            return base.Update(id, request);
        }

        [Authorize(Roles ="Admin,User")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [Authorize(Roles = "Admin")]
        public override PagedResult<User> GetList([FromQuery] UserSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize(Roles = "Admin")]
        public override User GetById(int id)
        {
            return base.GetById(id);
        }
    }
}
