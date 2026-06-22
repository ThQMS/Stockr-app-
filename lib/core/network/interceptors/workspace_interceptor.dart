import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class WorkspaceInterceptor extends Interceptor {
  const WorkspaceInterceptor(this._preferences);

  static const _workspaceKey = 'current_workspace_id';

  final SharedPreferences _preferences;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final workspaceId = _preferences.getString(_workspaceKey);
    if (workspaceId != null && workspaceId.isNotEmpty) {
      options.headers['X-Workspace-Id'] = workspaceId;
    }
    handler.next(options);
  }
}
