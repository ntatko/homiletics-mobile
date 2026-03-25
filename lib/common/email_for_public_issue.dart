/// Reduces exposure of the address in the prefilled GitHub issue body (browser fallback).
String obscureEmailForPublicIssue(String email) {
  final e = email.trim();
  if (e.isEmpty) return '_(not provided)_';
  final at = e.indexOf('@');
  if (at <= 0 || at >= e.length - 1) {
    return '_(provided; not shown on public issue)_';
  }
  final local = e.substring(0, at);
  final domain = e.substring(at + 1);
  if (local.isEmpty || domain.isEmpty) {
    return '_(provided; not shown on public issue)_';
  }
  final first = local.substring(0, 1);
  return '$first***@$domain';
}
