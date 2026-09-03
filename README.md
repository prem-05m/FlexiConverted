# FlexiConvert

FlexiConvert is a powerful local and cloud conversion tool built with Flutter (Frontend) and Node.js (Backend).

## Architecture
- **Frontend**: Flutter Android application (works with or without an active internet connection for local tasks).
- **Backend**: Node.js + Express.js API.
- **Database**: MongoDB Atlas.
- **Queue/Cache**: Cloud Redis (optional for basic functionality).

> [!IMPORTANT]
> This project operates **completely independently of Docker**. You do not need Docker to develop, run, test, or build this application.

## Development Setup

### Backend (Node.js)
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Configure the environment:
   - Copy `.env.example` to `.env`
   - Set `MONGODB_URI` to your MongoDB Atlas connection string.
   - Set `REDIS_URL` if you are using a cloud Redis provider for queue jobs.
4. Start the development server:
   ```bash
   npm run dev
   ```

### Frontend (Flutter Android App)
1. Navigate to the flutter directory:
   ```bash
   cd flexiconvert
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application (connects to local backend via `10.0.2.2` automatically in dev mode):
   ```bash
   flutter run
   ```

## Production Build

### Backend
1. Build the TypeScript code:
   ```bash
   npm run build
   ```
2. Start the production server:
   ```bash
   npm start
   ```

### Frontend (Play Store Release)
To generate a Google Play Store compatible Android App Bundle (AAB):
```bash
flutter build appbundle --release
```
To build a direct-install APK:
```bash
flutter build apk --release
```
