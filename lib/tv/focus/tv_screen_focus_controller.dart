import 'package:flutter/foundation.dart';

class TvScreenFocusController {
  Object? _owner;
  VoidCallback? _requestFocus;
  bool _pendingRequest = false;

  void attach(Object owner, VoidCallback requestFocus) {
    _owner = owner;
    _requestFocus = requestFocus;
    if (_pendingRequest) {
      _pendingRequest = false;
      requestFocus();
    }
  }

  void detach(Object owner) {
    if (!identical(_owner, owner)) return;
    _owner = null;
    _requestFocus = null;
  }

  void requestFocus() {
    final requestFocus = _requestFocus;
    if (requestFocus == null) {
      _pendingRequest = true;
      return;
    }
    requestFocus();
  }
}
