# ISN MyGOV Mock API Server

Mock backend API server simulating MyGOV Service for the ISN Accessible Bridge prototype.

## Features

- RESTful API endpoints for services, users, and applications
- Intent recognition (simulating Gemini AI)
- Batch application submission for offline sync
- Application status management with audit trail
- Statistics and debugging endpoints
- CORS enabled for Flutter app integration

## Installation

```bash
cd server
npm install
```

## Running the Server

### Development Mode (with auto-reload)
```bash
npm run dev
```

### Production Mode
```bash
npm start
```

The server will start on `http://localhost:3000` by default.

## API Endpoints

### Health Check
- `GET /api/health` - Check server status

### Services
- `GET /api/services` - Get all services
  - Query params: `category` (optional), `language` (optional)
- `GET /api/services/:id` - Get service by ID

### Users
- `GET /api/users/:uid` - Get user by UID

### Applications
- `POST /api/applications` - Submit new application
  - Body: `{ serviceId, uid, filledData, status? }`
- `POST /api/applications/batch` - Batch submit applications (for offline sync)
  - Body: `{ applications: [...] }`
- `GET /api/applications/user/:uid` - Get all applications for a user
- `GET /api/applications/:appId` - Get application by ID
- `PATCH /api/applications/:appId/status` - Update application status
  - Body: `{ status, details?, actor? }`

### Intent Recognition
- `POST /api/intent` - Recognize service intent from voice transcript
  - Body: `{ transcript, language? }`

### Statistics & Debug
- `GET /api/stats` - Get application statistics
- `DELETE /api/applications` - Clear all applications (testing only)

## Example Requests

### Submit Application
```bash
curl -X POST http://localhost:3000/api/applications \
  -H "Content-Type: application/json" \
  -d '{
    "serviceId": "welfare_relief_2025",
    "uid": "user_aminah",
    "filledData": {
      "income_proof": "2000",
      "household_size": "4",
      "reason": "Need assistance for family expenses"
    }
  }'
```

### Intent Recognition
```bash
curl -X POST http://localhost:3000/api/intent \
  -H "Content-Type: application/json" \
  -d '{
    "transcript": "mohon bantuan kebajikan",
    "language": "ms"
  }'
```

### Batch Submit (Offline Sync)
```bash
curl -X POST http://localhost:3000/api/applications/batch \
  -H "Content-Type: application/json" \
  -d '{
    "applications": [
      {
        "serviceId": "welfare_relief_2025",
        "uid": "user_david",
        "filledData": { "income_proof": "1500", "household_size": "5", "reason": "Economic hardship" },
        "status": "draft",
        "submittedAt": "2025-12-10T10:00:00Z"
      }
    ]
  }'
```

## Data Structure

### Application Object
```json
{
  "appId": "uuid",
  "serviceId": "service_id",
  "uid": "user_id",
  "status": "submitted|draft|processing|approved|rejected",
  "filledData": { "field": "value" },
  "submittedAt": "ISO timestamp",
  "updatedAt": "ISO timestamp",
  "audit": [
    {
      "timestamp": "ISO timestamp",
      "action": "submitted|status_changed",
      "details": "description",
      "actor": "uid|system"
    }
  ]
}
```

## Seed Data

The server loads seed data from `seed-data.json`:
- 3 demo users (Puan Aminah, Encik David, Cik Sarah)
- 3 government services (Welfare Relief, Business Permit, Scholarship)

## Development Notes

- In-memory storage (data is lost on restart)
- No authentication (prototype only)
- CORS enabled for all origins
- Detailed logging to console

## Integration with Flutter App

Update the Flutter app's API endpoint configuration:

```dart
// lib/config.dart
static const String apiBaseUrl = 'http://localhost:3000/api';
```

For Android emulator, use:
```dart
static const String apiBaseUrl = 'http://10.0.2.2:3000/api';
```

For physical device on same network:
```dart
static const String apiBaseUrl = 'http://YOUR_COMPUTER_IP:3000/api';
```

## License

MIT - Prototype use only
