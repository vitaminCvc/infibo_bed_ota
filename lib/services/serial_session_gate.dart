import 'dart:async';

class SerialLease {
  SerialLease._(this._gate);
  final SerialSessionGate _gate;
  bool _released = false;
  Future<void> release() async {
    if (_released) return;
    _released = true;
    await _gate._release(this);
  }
}

class SerialSessionGate {
  SerialLease? _owner;
  final _pending = <Future<void>>{};
  Future<T> run<T>(SerialLease? owner, Future<T> Function() action) async {
    if ((_owner != null && !identical(owner, _owner)) ||
        (owner != null && (owner._released || !identical(owner, _owner)))) {
      throw StateError('Serial port is reserved for an OTA session');
    }
    final pending = Completer<void>();
    _pending.add(pending.future);
    try {
      return await action();
    } finally {
      _pending.remove(pending.future);
      pending.complete();
    }
  }

  Future<SerialLease> acquire() async {
    if (_owner != null) throw StateError('Serial OTA session already active');
    final lease = SerialLease._(this);
    _owner = lease;
    await Future.wait(_pending.toList());
    return lease;
  }

  Future<void> _release(SerialLease lease) async {
    if (!identical(_owner, lease)) return;
    await Future.wait(_pending.toList());
    if (identical(_owner, lease)) _owner = null;
  }
}
