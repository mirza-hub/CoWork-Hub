using CoWorkHub.Model;
using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;
using MapsterMapper;

namespace CoWorkHub.Services.Interfaces
{
    public interface IUserService : ICRUDService<Model.User, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
        User Login(string username, string password);
        public Model.User UpdateForAdmin(int id, UserAdminUpdateRequest request);
        Model.PasswordResetRequest SendPasswordResetCode(PasswordResetRequestRequest request);
        User RestoreUser(int id);
        bool VerifyResetCode(string email, string code);
        void ResetPassword(string email, string newPassword, string newPasswordConfirm);
    }
}
