import 'package:equatable/equatable.dart';

class Workspace extends Equatable {
  const Workspace({
    required this.id,
    required this.name,
    this.role,
  });

  final String id;
  final String name;
  final String? role;

  @override
  List<Object?> get props => [id, name, role];
}
