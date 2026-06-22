import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

final class ConnectivityPlusNetworkInfo implements NetworkInfo {
  const ConnectivityPlusNetworkInfo(this._connectivity);

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result.any((status) => status != ConnectivityResult.none);
  }
}
