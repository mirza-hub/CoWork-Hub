using CoWorkHub.Model;
using CoWorkHub.Model.Exceptions;
using CoWorkHub.Model.Requests;
using CoWorkHub.Model.SearchObjects;
using CoWorkHub.Services.Auth;
using CoWorkHub.Services.Database;
using CoWorkHub.Services.Interfaces;
using CoWorkHub.Services.Services.BaseServicesImplementation;
using MapsterMapper;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace CoWorkHub.Services.Services
{
    public class PaymentService : BaseCRUDService<Model.Payment, PaymentSearchObject, Database.Payment, PaymentInsertRequest, PaymentUpdateRequest>, IPaymentService
    {
        private readonly IReservationService _reservationService;
        private readonly ICurrentUserService _currentUserService;
        private readonly IActivityLogService _activityLogService;
        private readonly INotificationService _notificationService;

        public PaymentService(_210095Context context, IMapper mapper, 
            IReservationService reservationService,
            IActivityLogService activityLogService,
            ICurrentUserService currentUserService,
            INotificationService notificationService
            )
            : base(context, mapper) 
        {
            _reservationService = reservationService;
            _activityLogService = activityLogService;
            _currentUserService = currentUserService;
            _notificationService = notificationService;
        }

        public override IQueryable<Database.Payment> AddFilter(PaymentSearchObject search, IQueryable<Database.Payment> query)
        {
            query = base.AddFilter(search, query);

            if (search.PaymentId.HasValue)
                query = query.Where(x => x.PaymentId == search.PaymentId);

            if (search.ReservationId.HasValue)
                query = query.Where(x => x.ReservationId == search.ReservationId);

            if (search.PaymentMethodId.HasValue)
                query = query.Where(x => x.PaymentMethodId == search.PaymentMethodId);

            if (!string.IsNullOrWhiteSpace(search.StateMachine))
                query = query.Where(x => x.StateMachine == search.StateMachine);

            if (search.DateFrom.HasValue)
                query = query.Where(x => x.PaymentDate >= search.DateFrom);

            if (search.DateTo.HasValue)
                query = query.Where(x => x.PaymentDate <= search.DateTo);

            if (search.PriceFrom.HasValue)
                query = query.Where(x => x.TotalPaymentAmount >= search.PriceFrom);

            if (search.PriceTo.HasValue)
                query = query.Where(x => x.TotalPaymentAmount <= search.PriceTo);

            return query;
        }

        public override void BeforeInsert(PaymentInsertRequest request, Database.Payment entity)
        {
            base.BeforeInsert(request, entity);

            var reservation = Context.Reservations.Find(request.ReservationId);
            if (reservation == null)
                throw new UserException("Rezervacija ne postoji.");

            entity.PaymentDate = DateTime.UtcNow;
            entity.CreatedAt = DateTime.UtcNow;
            entity.StateMachine = "paid";
        }

        public override void AfterInsert(PaymentInsertRequest request, Database.Payment entity)
        {
            base.AfterInsert(request, entity);

            var reservation = Context.Reservations.Find(request.ReservationId);
            if (reservation == null)
                throw new UserException("Rezervacija ne postoji.");

            _reservationService.Confirm(reservation.ReservationId);

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "CREATE",
            "Payment",
            $"Kreirano plaćanje {entity.PaymentId}");
            _notificationService.Insert(new NotificationInsertRequest
            {
                UserId = _currentUserId,
                Message = $"Uspješno ste izvršili plaćanje rezervacije za {reservation.SpaceUnit.Name} u periodu {reservation.StartDate.ToString("dd.MM.yyyy")}-{reservation.EndDate.ToString("dd.MM.yyyy")} za {reservation.PeopleCount} osoba."
            });

            var adminIds = Context.UserRoles
                .Where(ur => ur.Role.RoleName == "Admin")
                .Select(ur => ur.UserId)
                .ToList();

            string _currentUserId2 = "Test";
            Database.User? _currentUser = _currentUserService.GetCurrentUser();
            if (_currentUser != null)
            {
                _currentUserId2 = _currentUser.FirstName + " " + _currentUser.LastName;
            }

            foreach (var adminId in adminIds)
            {
                _notificationService.Insert(new NotificationInsertRequest
                {
                    UserId = adminId,
                    Message = $"{_currentUserId2} je uspješno izvršio plaćanje rezervacije za {reservation.SpaceUnit.Name} u periodu {reservation.StartDate.ToString("dd.MM.yyyy")}-{reservation.EndDate.ToString("dd.MM.yyyy")} za {reservation.PeopleCount} osoba."
                });
            }
        }

        public override void BeforeUpdate(PaymentUpdateRequest request, Database.Payment entity)
        {
            base.BeforeUpdate(request, entity);

            entity.ModifiedAt = DateTime.UtcNow;

            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "UPDATE",
            "Payment",
            $"Ažurirano plaćanje {entity.PaymentId}");
        }

        public override void AfterDelete(Database.Payment entity)
        {
            base.AfterDelete(entity);
            int _currentUserId = (int)_currentUserService.GetUserId();
            _activityLogService.LogAsync(
            _currentUserId,
            "DELETE",
            "Payment",
            $"Obrisano plaćanje {entity.PaymentId}");
        }

        public async Task<string> CreatePaypalOrder(decimal amount)
        {
            var clientId = Environment.GetEnvironmentVariable("PAYPAL_CLIENT_ID");
            var secret = Environment.GetEnvironmentVariable("PAYPAL_SECRET");
            var baseUrl = "https://api-m.sandbox.paypal.com";

            // Dobavljanje access tokena
            var authToken = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{clientId}:{secret}"));
            using var client = new HttpClient();
            client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Basic", authToken);

            var tokenResponse = await client.PostAsync($"{baseUrl}/v1/oauth2/token",
                new FormUrlEncodedContent(new Dictionary<string, string> { { "grant_type", "client_credentials" } }));

            tokenResponse.EnsureSuccessStatusCode();
            var tokenContent = await tokenResponse.Content.ReadAsStringAsync();
            var tokenJson = JsonDocument.Parse(tokenContent);
            var accessToken = tokenJson.RootElement.GetProperty("access_token").GetString();

            // Kreiranje ordera
            using var orderClient = new HttpClient();
            orderClient.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", accessToken);
            orderClient.DefaultRequestHeaders.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));

            // pripremi payload sa camelCase i string amount
            var orderData = new
            {
                intent = "CAPTURE",
                purchase_units = new[]
                {
            new
            {
                amount = new
                {
                    currency_code = Environment.GetEnvironmentVariable("PAYPAL_CURRENCY"),
                    value = amount.ToString("F2",CultureInfo.InvariantCulture)
                }
            }
        },
                application_context = new
                {
                    return_url = Environment.GetEnvironmentVariable("PAYPAL_SUCCESS_URL"),
                    cancel_url = Environment.GetEnvironmentVariable("PAYPAL_CANCEL_URL")
        }
            };

            var jsonOptions = new JsonSerializerOptions
            {
                PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                WriteIndented = false
            };

            var content = new StringContent(JsonSerializer.Serialize(orderData, jsonOptions), Encoding.UTF8, "application/json");

            var orderResponse = await orderClient.PostAsync($"{baseUrl}/v2/checkout/orders", content);
            var orderJson = await orderResponse.Content.ReadAsStringAsync();

            Console.WriteLine("PayPal create order response: " + orderJson);

            orderResponse.EnsureSuccessStatusCode();

            return orderJson;
        }

        public async Task<string> CapturePaypalOrder(string orderId)
        {
            var clientId = Environment.GetEnvironmentVariable("PAYPAL_CLIENT_ID");
            var secret = Environment.GetEnvironmentVariable("PAYPAL_SECRET");
            var baseUrl = "https://api-m.sandbox.paypal.com";

            // Dobavljanje access tokena
            var authToken = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{clientId}:{secret}"));
            using var client = new HttpClient();
            client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Basic", authToken);

            var tokenResponse = await client.PostAsync($"{baseUrl}/v1/oauth2/token",
                new FormUrlEncodedContent(new Dictionary<string, string> { { "grant_type", "client_credentials" } }));

            tokenResponse.EnsureSuccessStatusCode();
            var tokenContent = await tokenResponse.Content.ReadAsStringAsync();
            var tokenJson = JsonDocument.Parse(tokenContent);
            var accessToken = tokenJson.RootElement.GetProperty("access_token").GetString();

            // Capture ordera
            using var captureClient = new HttpClient();
            captureClient.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", accessToken);
            captureClient.DefaultRequestHeaders.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json"));

            var captureUrl = $"{baseUrl}/v2/checkout/orders/{orderId}/capture";
            var captureResponse = await captureClient.PostAsync(captureUrl, new StringContent("", Encoding.UTF8, "application/json"));

            captureResponse.EnsureSuccessStatusCode();
            var captureJson = await captureResponse.Content.ReadAsStringAsync();

            return captureJson;
        }
    }
}
