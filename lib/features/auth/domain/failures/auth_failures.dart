import '../../../../core/error/failures.dart';

AuthFailure invalidCredentialsFailure() {
  return const AuthFailure('Invalid e-mail or password');
}

AuthFailure sessionExpiredFailure() {
  return const AuthFailure('Session expired');
}
