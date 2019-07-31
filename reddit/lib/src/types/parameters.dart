
part 'parameters/listing_parameters.dart';
part 'parameters/sort_parameters.dart';

abstract class Parameter {

  const Parameter._(this.name, [String value])
    : this.value = value ?? name;

  final String name;

  final String value;
}
