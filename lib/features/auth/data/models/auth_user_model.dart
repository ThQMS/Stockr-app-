import '../../domain/entities/auth_user.dart';
import 'workspace_model.dart';

final class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.email,
    required super.name,
    required List<WorkspaceModel> super.workspaces,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final workspaces = (json['workspaces'] as List<dynamic>? ?? [])
        .map((item) => WorkspaceModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return AuthUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      workspaces: workspaces,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'workspaces': workspaces
          .map(
            (workspace) => WorkspaceModel(
              id: workspace.id,
              name: workspace.name,
              role: workspace.role,
            ).toJson(),
          )
          .toList(),
    };
  }
}
