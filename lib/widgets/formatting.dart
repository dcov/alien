
const _kSecondsInAMinute = 60;
const _kSecondsInAnHour = _kSecondsInAMinute * 60;
const _kSecondsInADay = _kSecondsInAnHour * 24;
const _kSecondsInAWeek = _kSecondsInADay * 7;
const _kSecondsInAMonth = _kSecondsInADay * 30;
const _kSecondsInAYear = _kSecondsInADay * 365;

String formatElapsedUtc(int startingUtcSeconds, { String append = ''}) {

  final elapsedTime = (DateTime.now().millisecondsSinceEpoch / 1000) - startingUtcSeconds;

  String? formatValue(double value, String postfix) => value > 1 ? '${value.ceil()}$postfix' : null;

  final formattedElapsedTime = formatValue(elapsedTime/_kSecondsInAYear, 'y') ??
                               formatValue(elapsedTime / _kSecondsInAMonth, 'mo') ??
                               formatValue(elapsedTime / _kSecondsInAWeek, 'w') ??
                               formatValue(elapsedTime / _kSecondsInADay, 'd') ??
                               formatValue(elapsedTime / _kSecondsInAnHour, 'h') ??
                               formatValue(elapsedTime / _kSecondsInAMinute, 'm') ??
                               formatValue(elapsedTime, 's');

  return '$formattedElapsedTime ago';
}

String formatCount(int count) {
  if (count > 1000000)
    return '${(count / 1000000).toStringAsFixed(1)}m';
  else if (count > 100000)
    return '${(count / 1000).floor()}k';
  else if (count > 1000)
    return '${(count / 1000).toStringAsFixed(1)}k';
  else
    return count.toString();
}
