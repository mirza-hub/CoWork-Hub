using CoWorkHub.Api.Controllers.BaseControllers;
using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;
using CoWorkHub.Services.Services;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading;

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

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/update_for_admin")]
        public Model.User UpdateForAdmin(int id, UserAdminUpdateRequest request)
        {
            return (_service as IUserService).UpdateForAdmin(id, request);
        }

        [Authorize(Roles ="Admin,User")]
        public override void Delete(int id)
        {
            base.Delete(id);
        }

        [Authorize]
        public override PagedResult<User> GetList([FromQuery] UserSearchObject searchObject)
        {
            return base.GetList(searchObject);
        }

        [Authorize]
        public override User GetById(int id)
        {
            return base.GetById(id);
        }

        [Authorize(Roles = "Admin")]
        [HttpPut("{id}/restore")]
        public User RestoreUser(int id)
        {
            return (_service as IUserService).RestoreUser(id);
        }

        [AllowAnonymous]
        [HttpPost("password-reset/send-code")]
        public Model.PasswordResetRequest SendPasswordResetCode([FromBody] PasswordResetRequestRequest request)
        {
            return (_service as IUserService).SendPasswordResetCode(request);
        }

        [AllowAnonymous]
        [HttpPost("password-reset/verify-code")]
        public bool VerifyResetCode([FromBody] VerifyResetCode request)
        {
            return (_service as IUserService).VerifyResetCode(request.Email, request.Code);
        }

        [AllowAnonymous]
        [HttpPost("password-reset/new-password")]
        public void ResetPassword([FromBody] ResetPassword request)
        {
            (_service as IUserService).ResetPassword(request.Email, request.NewPassword, request.NewPasswordConfirm);
        }
    }
}
