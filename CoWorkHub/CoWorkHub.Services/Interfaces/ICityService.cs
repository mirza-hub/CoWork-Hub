using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;

namespace CoWorkHub.Services.Interfaces
{
    public interface ICityService : ICRUDService<City, CitySearchObject, CityInsertRequest, CityUpdateRequest>
    { 
        City RestoreCity(int id);
    }
}
