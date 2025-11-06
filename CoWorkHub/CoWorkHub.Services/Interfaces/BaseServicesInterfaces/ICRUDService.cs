using CoWorkHub.Model.SearchObjects;

namespace CoWorkHub.Services.Interfaces.BaseServicesInterfaces
{
    public interface ICRUDService<TModel, TSearch, TInsert, TUpdate> 
        : IService<TModel, TSearch> where TModel : class where TSearch : BaseSearchObject
    {
        TModel Insert(TInsert request);
        TModel Update(int id, TUpdate request);
        void Delete(int id);
    }
}
