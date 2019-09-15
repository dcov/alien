part of 'app.dart';

abstract class AppState extends Model {

  factory AppState() => _$AppState(initialized: false);

  bool initialized;
}
