part 'listing_parameters.dart';
part 'misc_parameters.dart';
part 'sort_parameters.dart';

abstract class Parameter {

  const Parameter._(this.name, [String value])
    : this.value = value ?? name;

  final String name;

  final String value;

  @override
  String toString() => this.value;
}

