using CoWorkHub.Model;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Interfaces.BaseServicesInterfaces;

namespace CoWorkHub.Services.Interfaces
{
    public interface ICountryService : ICRUDService<Country, CountrySearchObject, CountryInsertRequest, CountryUpdateRequest> 
    {
        Country RestoreCountry(int id);
    }
}
