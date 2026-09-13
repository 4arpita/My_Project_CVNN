# Child Vaccination Notifier System

Full-stack microservices project following the mentor-style Repository-Service-Controller structure with simple DTOs, Lombok, JWT security, MySQL, React, ASP.NET Core and FastAPI.

## Updated features

- Tailwind-only React frontend using the provided professional visual design, simple functional components, React Router, Axios service configuration, and React Toastify.
- Parent location saved as latitude and longitude.
- Parent and clinic locations selected by search, map click, marker drag or browser geolocation.
- Completely keyless map stack: React Leaflet, Leaflet and OpenStreetMap.
- Address search through a Spring Boot Nominatim proxy only when the user presses Search; no automatic request on every keystroke. The backend limits public requests and caches repeated searches for 24 hours.
- Road route preview and estimated driving time through OSRM.
- OpenStreetMap directions link for navigation.
- Nearby results contain only active, verified clinics added to this application.
- Registered clinics can be selected and opened directly in appointment booking.
- ASP.NET Core email service using MailKit SMTP.
- GroqCloud chatbot using FastAPI and the official Groq Python SDK with `llama-3.3-70b-versatile`.
- Ollama and Google Maps are completely removed.

## Free map services

No map API key, billing account or card is needed.

| Requirement | Service |
|---|---|
| Interactive React map | React Leaflet + Leaflet |
| Map tiles and map data | OpenStreetMap |
| Current parent location | Browser Geolocation API |
| Address/place search | Nominatim |
| Nearby clinics | Clinics stored in the application database |
| Road route and duration | OSRM |

The frontend displays the required `© OpenStreetMap contributors` attribution. Public OpenStreetMap community services are intended for limited and fair usage. For a large production deployment, self-host these services or use a provider with an SLA.

## Services and ports

| Service | Folder | Port |
|---|---|---:|
| React frontend | `frontend-react` | 5173 |
| Spring Boot API | `backend-springboot` | 8080 |
| ASP.NET email service | `email-service-dotnet` | 8081 |
| FastAPI Groq chatbot | `chatbot-service-python` | 8000 |
| MySQL Docker host port | Docker service | 3307 |

## Configuration

Copy `.env.example` to `.env` in the project root:

```bat
copy .env.example .env
```

Edit `.env` and provide:

1. `GROQ_API_KEY`
   - Create a GroqCloud API key.
   - The default model is `llama-3.3-70b-versatile`.

2. SMTP values
   - Set `SMTP_ENABLED=true`.
   - For Gmail, use an App Password instead of the normal account password.
   - Set `SMTP_USERNAME`, `SMTP_PASSWORD` and `SMTP_FROM_EMAIL`.

There is no map key configuration because the selected map stack is keyless. Optional service endpoints can be changed in `.env` without changing source code:

```env
NOMINATIM_BASE_URL=https://nominatim.openstreetmap.org
VITE_OSM_TILE_URL=https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png
VITE_OSRM_URL=https://router.project-osrm.org
```


## Secret-key safety

Never commit or share `.env`. If a Groq API key or Gmail App Password appears in chat, screenshots, logs, or Git history, revoke it immediately and create a replacement. The ZIP contains placeholders only. For Gmail, put the 16-character App Password in `.env` without spaces and set `SMTP_FROM_EMAIL` to the same mailbox as `SMTP_USERNAME`.

## Run using Docker Desktop

1. Install and start Docker Desktop.
2. Create `.env` from `.env.example` and enter the Groq and SMTP values.
3. Open Command Prompt in this project folder.
4. Run:

```bat
docker compose up --build
```

5. Open:

- Frontend: `http://localhost:5173`
- Swagger: `http://localhost:8080/api/swagger-ui/index.html`
- Email health: `http://localhost:8081/health`
- Chatbot health: `http://localhost:8000/health`


## Reliable Windows chatbot setup

The chatbot intentionally does **not** install LangChain or LangSmith. The official Groq SDK (`groq==1.6.0`) is sufficient and avoids Windows deep-path installation failures.

Do not recreate `.venv` while it is activated. The provided script uses the short path `%LOCALAPPDATA%\CVNS\chatbot-venv` instead of placing a virtual environment inside a deeply nested project directory.

1. Close every old Uvicorn/Python terminal.
2. Delete the old project `.venv` folder if it exists.
3. Create the root `.env` from `.env.example`; the Windows scripts load it automatically.
4. For the first clean installation, double-click or run:

```bat
chatbot-service-python\reset-chatbot-windows.bat
```

5. In another PowerShell window, test it:

```powershell
powershell -ExecutionPolicy Bypass -File chatbot-service-python\test-chatbot-windows.ps1
```

Manual commands from a short folder are also supported:

```bat
cd /d C:\cvns\chatbot-service-python
py -3.12 -m venv %LOCALAPPDATA%\CVNS\chatbot-venv
call %LOCALAPPDATA%\CVNS\chatbot-venv\Scripts\activate.bat
python -m pip install --upgrade pip setuptools wheel
python -m pip install --no-cache-dir -r requirements.txt
python -m uvicorn main:app --host 127.0.0.1 --port 8000
```

## Map flow

### Parent

- During registration or from Profile, search for an address, click the map, drag the marker, or use current location.
- Open **Nearby Clinics** and select a radius.
- The backend returns only active, verified clinics stored in the application database, sorted by distance.
- Select a marker or result card to preview the OSRM road route and estimated distance and duration.
- Use **Get directions** for the OpenStreetMap directions page.
- Use **Book appointment** to continue with the selected clinic.

### Clinic/Hospital

- During clinic registration, select the exact coordinates on OpenStreetMap.
- Clinic users can update the location from the clinic dashboard.
- Admin can add or edit clinic locations using the same map picker.

## Test the email service

PowerShell:

```powershell
Invoke-RestMethod -Method Post "http://localhost:8081/api/email/test?to=your-email@gmail.com"
```

Check configuration:

```text
http://localhost:8081/api/email/configuration
```

## Test the Groq chatbot

Open:

```text
http://localhost:8000/health
```

Expected after setting `GROQ_API_KEY`:

```json
{
  "status": "UP",
  "provider": "GroqCloud",
  "sdk": "groq-python",
  "model": "llama-3.3-70b-versatile",
  "apiKeyConfigured": true
}
```


## Email OTP verification

New parent and clinic accounts must verify their email before login.

1. Register from the frontend.
2. A 6-digit OTP is sent through the ASP.NET MailKit service.
3. Enter the OTP within 10 minutes.
4. Use **Resend OTP** after the 60-second cooldown when needed.
5. After successful verification, the application signs the user in automatically.

Public authentication APIs:

- `POST /api/auth/register`
- `POST /api/auth/verify-email-otp`
- `POST /api/auth/resend-email-otp`
- `POST /api/auth/login`

SMTP must be correctly configured in the root `.env` file for new registrations. The seeded demo accounts are already verified.

## Demo accounts

| Role | Email | Password |
|---|---|---|
| Admin | `admin@cvns.com` | `Admin@123` |
| Parent | `parent@cvns.com` | `Parent@123` |
| Clinic | `clinic@cvns.com` | `Clinic@123` |

The demo parent and clinic contain Pune coordinates. The seeded clinic is verified.

## Stop or reset

```bat
docker compose down
```

Delete MySQL data and start fresh:

```bat
docker compose down -v
```

## Common problems

### Map tiles do not load

- Confirm the computer has internet access.
- Disable aggressive ad/privacy blocking for localhost if it blocks tile requests.
- Do not repeatedly refresh or automate large numbers of requests against public community services.

### Nearby clinics are empty

- Confirm the admin has added, verified, and activated clinics.
- Confirm each clinic has valid latitude and longitude values.
- Increase the selected search radius if required.

### Address search does not return a result

- Enter a more specific city, area or address and press Search.
- Search is deliberately button-triggered rather than autocomplete to follow public Nominatim fair-use guidance.

### Chatbot configuration error

```bat
docker compose restart chatbot-service backend
```

Confirm `GROQ_API_KEY` is valid.

### Email is not sent

- Use a Gmail App Password.
- Confirm `SMTP_ENABLED=true`, port `587`, and host `smtp.gmail.com`.
- Check logs:

```bat
docker compose logs email-service
```

## Chatbot 422 troubleshooting

The Python endpoint expects an HTTP POST request with JSON:

```json
{"message":"Which vaccines are due at 6 weeks?"}
```

Test it with PowerShell:

```powershell
Invoke-RestMethod -Method POST -Uri http://localhost:8000/api/chat -ContentType "application/json" -Body '{"message":"Which vaccines are due at 6 weeks?"}'
```

`Unsupported upgrade request` is normally caused by a WebSocket or HTTPS request being sent to the plain HTTP Uvicorn port. Use `http://localhost:8000`, not `https://` or `ws://`.
