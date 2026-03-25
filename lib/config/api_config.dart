/// Base URL for homiletics-api (passages, feedback, errors).
///
/// Production: [api.homiletics.app](https://api.homiletics.app).
/// Override at build time: `--dart-define=HOMILETICS_API_BASE=https://...`
const String kHomileticsApiBase = String.fromEnvironment(
  'HOMILETICS_API_BASE',
  defaultValue: 'https://api.homiletics.app',
);
