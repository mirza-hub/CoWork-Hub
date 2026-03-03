# CoWork-Hub
Seminarski rad iz predmeta Razvoj softvera 2 na Fakultetu informacijskih tehnologija u Mostaru.

---

## 📌 Upute za pokretanje
### Backend (env)
1. Extractovati: `fit-build-2026-03-03 - env`
2. Postaviti `.env` fajl u: `CoWork-Hub\CoWorkHub`
3. Otvoriti `CoWork-Hub\CoWorkHub` u terminalu i pokrenuti komandu:
docker-compose up --build
### Desktop aplikacija
1. Extractovati: `fit-build-2026-03-03 - desktop`
2. Pokrenuti `coworkhub_desktop.exe` koji se nalazi u folderu `Release`
3. Unijeti desktop kredencijale koji se mogu pronaći u ovom README-u

### Mobilna aplikacija
1. Prije pokretanja, provjeriti da aplikacija već ne postoji na Android emulatoru; ukoliko postoji, deinstalirati je 
2. Extractovati: `fit-build-2026-03-03 - mobile`
3. Na pokrenuti emulator prenijeti fajl `app-release.apk` iz foldera `flutter-apk` i sačekati instalaciju
4. Pokrenuti aplikaciju i unijeti mobilne kredencijale koji se mogu pronaći u ovom README-u
## 🔑 Kredencijali za prijavu

### Mobilna aplikacija

**User**
- Korisničko ime: `mobile`
- Lozinka: `test`

### Desktop aplikacija

**Admin**
- Korisničko ime: `desktop`
- Lozinka: `test`

---

## 💳 PayPal Kredencijali
- Email: `coworkhub_personal@personal.example.com`
- Lozinka: `coworkhubtest`
- Plaćanje se odvija na mobilnoj aplikaciji kada korisnik nakon uspješne rezervacije plaća rezervaciju, ako to ne želi može je kasnije kasnije platiti u tabu Historija rezervacija.

---

## 🐇 RabbitMQ
- RabbitMQ je korišten za slanje mailova kada se novi korisnik tek registruje na stranicu i kada je korisnik zaboravio šifru onda ostavi svoj mail na koji mu dođe kod koji ga vodi na ekran gdje unosi novu šifru