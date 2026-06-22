import 'package:equatable/equatable.dart';

final class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
