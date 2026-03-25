/// [study] may be a host path (e.g. `bsfinternational.org/john`) or a full URL.
Uri studyLaunchUri(String study) {
  final s = study.trim();
  final lower = s.toLowerCase();
  if (lower.startsWith('http://') || lower.startsWith('https://')) {
    return Uri.parse(s);
  }
  return Uri.parse('https://$s');
}
