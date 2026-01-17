import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../services/db_service.dart';

class AccountViewModel extends ChangeNotifier {
  static const _balanceKey = 'balance';
  final DbService _db = DbService();
  double _balance = 50.0; // start value
  String _lastPix = '';
  List<Map<String, dynamic>> _depositHistory = [];
  double _totalDeposited = 0.0;

  String get lastPix => _lastPix;

  AccountViewModel() {
    _load();
  }

  String get balanceFormatted =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_balance);
  double get balance => _balance;

  Future<void> _load() async {
    final val = await _db.readValue(_balanceKey);
    if (val == null) {
      _balance = 50.0;
      await _db.saveValue(_balanceKey, _balance.toString());
    } else {
      _balance = double.tryParse(val) ?? 50.0;
    }
    final pix = await _db.readValue('last_pix');
    _lastPix = pix ?? '';
    // load deposit history
    final hist = await _db.readValue('deposit_history');
    if (hist != null && hist.isNotEmpty) {
      try {
        final decoded = jsonDecode(hist) as List<dynamic>;
        _depositHistory = decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _totalDeposited = _depositHistory.fold(0.0, (s, e) => s + (e['amount'] as num).toDouble());
      } catch (_) {
        _depositHistory = [];
        _totalDeposited = 0.0;
      }
    }
    notifyListeners();
  }

  Future<void> setBalance(double newBalance) async {
    _balance = newBalance;
    await _db.saveValue(_balanceKey, _balance.toString());
    notifyListeners();
  }

  List<Map<String, dynamic>> get depositHistory => List.unmodifiable(_depositHistory);
  double get totalDeposited => _totalDeposited;
  String get totalDepositedFormatted =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(_totalDeposited);

  // Visual withdraw: store pix key and reduce balance by amount if possible
  Future<bool> withdraw(String pixKey, double amount) async {
    if (amount <= 0 || amount > _balance) return false;
    _balance -= amount;
    await _db.saveValue(_balanceKey, _balance.toString());
    await _db.saveValue('last_pix', pixKey);
    _lastPix = pixKey;
    notifyListeners();
    return true;
  }

  /// Attempts to place a bet. On success returns the previous balance (before deduction).
  /// Returns null on failure.
  Future<double?> tryPlaceBet(double amount) async {
    if (amount <= 0) return null;
    if (_balance <= 0) return null;
    if (amount > _balance) return null;
    final prev = _balance;
    _balance -= amount;
    await _db.saveValue(_balanceKey, _balance.toString());
    notifyListeners();
    return prev;
  }

  Future<void> credit(double amount) async {
    _balance += amount;
    await _db.saveValue(_balanceKey, _balance.toString());
    notifyListeners();
  }

  /// Deposit helper for the UI: records deposit, updates lastPix if empty, and saves history
  Future<void> depositFixed(double amount) async {
    if (amount <= 0) return;
    _balance += amount;
    await _db.saveValue(_balanceKey, _balance.toString());

    // ensure we have a lastPix; if empty, generate a mocked one
    if (_lastPix.isEmpty) {
      _lastPix = _generateMockPix();
      await _db.saveValue('last_pix', _lastPix);
    }

    final entry = {'amount': amount, 'ts': DateTime.now().toIso8601String()};
    _depositHistory.add(entry);
    _totalDeposited += amount;
    try {
      await _db.saveValue('deposit_history', jsonEncode(_depositHistory));
    } catch (_) {}

    notifyListeners();
  }

  String _generateMockPix() {
    // simple mock: BR key like 'zz-xxxx-YYYY' using random
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    String pick(int n) => List.generate(n, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'pix-${pick(6)}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
  }
}
