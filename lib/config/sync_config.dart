/// Base URL for the sync/auth API. Change for homelab or production.
///
/// **Web:** Sync uses a browser HTTP client with credentials so any `Set-Cookie`
/// from the API is honored. The access token is still sent as
/// `Authorization: Bearer` and stored in preferences (localStorage on web).
/// When the web app is on another origin, set `CORS_ALLOWED_ORIGINS` on the API
/// (see `homiletics-api/lib/cors_middleware.dart`).
const String syncApiBaseUrl = 'https://api.homiletics.app';
