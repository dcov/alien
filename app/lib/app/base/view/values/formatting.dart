
const _kSecondsInAMinute = 60;
const _kSecondsInAnHour = _kSecondsInAMinute * 60;
const _kSecondsInADay = _kSecondsInAnHour * 24;
const _kSecondsInAWeek = _kSecondsInADay * 7;
const _kSecondsInAMonth = _kSecondsInADay * 30;
const _kSecondsInAYear = _kSecondsInADay * 365;

String _formatValue(double value, String postfix) {
  return value > 1 ? '${value.ceil()}$postfix' : null;
}

String formatElapsedUtc(int startingUtcSeconds, { String append = ''}) {

  final elapsedTime = (DateTime.now().millisecondsSinceEpoch / 1000) - startingUtcSeconds;

  return _formatValue(elapsedTime/_kSecondsInAYear, 'y') ??
         _formatValue(elapsedTime / _kSecondsInAMonth, 'mo') ??
         _formatValue(elapsedTime / _kSecondsInAWeek, 'w') ??
         _formatValue(elapsedTime / _kSecondsInADay, 'd') ??
         _formatValue(elapsedTime / _kSecondsInAnHour, 'h') ??
         _formatValue(elapsedTime / _kSecondsInAMinute, 'm') ??
         _formatValue(elapsedTime, 's');
}

String formatCount(int count) {
  if (count == null)
    return '0';
  if (count < 1000)
    return '$count';
  return (count / 1000).toStringAsPrecision(2) + 'k';
}