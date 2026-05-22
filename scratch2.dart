import 'package:flutter/material.dart';
class AuthRefreshStream extends ChangeNotifier {
  AuthRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }
  late final _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
