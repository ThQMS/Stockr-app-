import 'package:equatable/equatable.dart';

import 'workspace.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.workspaces,
  });

  final String id;
  final String email;
  final String name;
  final List<Workspace> workspaces;

  @override
  List<Object?> get props => [id, email, name, workspaces];
}
