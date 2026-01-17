import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/slot_item.dart';

class SlotViewModel extends ChangeNotifier {
  final Random _random = Random();
  bool _isSpinning = false;
  // 3x3 matrix stored row-major
  List<SlotItem> _matrix = List.generate(9, (_) => const SlotItem(SlotSymbol.tiger));
  // list of winning lines (each line is list of indices)
  List<List<int>> _winningLines = [];
  String _message = '';

  bool get isSpinning => _isSpinning;
  List<SlotItem> get matrix => _matrix;
  List<List<int>> get winningLines => _winningLines;
  String get message => _message;
  double _lastWin = 0.0;
  double get lastWin => _lastWin;
  bool _isMaxBonus = false;
  bool get isMaxBonus => _isMaxBonus;

  void resetMessage() {
    _message = '';
    notifyListeners();
  }

  /// Clear only the visual winning lines (leave message intact if desired).
  void clearWinningLines() {
    _winningLines = [];
    notifyListeners();
  }

  Future<void> spin() async {
    if (_isSpinning) return;
    _isSpinning = true;
    _message = '';
    _winningLines = []; // clear previous visual combos
    _lastWin = 0.0;
    _isMaxBonus = false;
    notifyListeners();

    // animate by changing symbols several times (slower)
    const int rounds = 24;
    for (int r = 0; r < rounds; r++) {
      _matrix = List.generate(
        9,
        (_) => SlotItem(SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)]),
      );
      notifyListeners();
      await Future.delayed(Duration(milliseconds: 90 + (r * 12)));
    }

    // Decide outcome with probabilities:
    // jackpot 5%, triple 10%, double 20%, single 50%, otherwise loss (15%)
    final roll = _random.nextInt(100); // 0..99
    if (roll < 5) {
      // jackpot - make all equal
      final sym = SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)];
      _matrix = List.generate(9, (_) => SlotItem(sym));
      _winningLines = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6],
      ];
      _message = 'JACKPOT!';
    } else if (roll < 15) {
      // triple combos (10%)
      final sym = SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)];
      _matrix = List.generate(
        9,
        (_) => SlotItem(SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)]),
      );
      final allLines = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6],
      ];
      final toPick = 3;
      final idxs = List<int>.generate(allLines.length, (i) => i)..shuffle(_random);
      for (int i = 0; i < toPick; i++) {
        final l = allLines[idxs[i]];
        for (final pos in l) _matrix[pos] = SlotItem(sym);
        _winningLines.add(l);
      }
      _message = 'Ganhou!';
    } else if (roll < 35) {
      // double combos (20%)
      final sym = SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)];
      _matrix = List.generate(
        9,
        (_) => SlotItem(SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)]),
      );
      final allLines = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6],
      ];
      final toPick = 2;
      final idxs = List<int>.generate(allLines.length, (i) => i)..shuffle(_random);
      for (int i = 0; i < toPick; i++) {
        final l = allLines[idxs[i]];
        for (final pos in l) _matrix[pos] = SlotItem(sym);
        _winningLines.add(l);
      }
      _message = 'Ganhou!';
    } else if (roll < 85) {
      // single combo (50%)
      final sym = SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)];
      _matrix = List.generate(
        9,
        (_) => SlotItem(SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)]),
      );
      final allLines = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6],
      ];
      final toPick = 1;
      final idxs = List<int>.generate(allLines.length, (i) => i)..shuffle(_random);
      for (int i = 0; i < toPick; i++) {
        final l = allLines[idxs[i]];
        for (final pos in l) _matrix[pos] = SlotItem(sym);
        _winningLines.add(l);
      }
      _message = 'Ganhou!';
    } else {
      // no combos (15% loss)
      _message = 'Tente de novo!';
      _winningLines = [];
    }

    _isSpinning = false;
    notifyListeners();
  }

  /// Spin with a bet amount. `creditCallback` will be called with amount to credit on win.
  /// spinWithBet now takes the user's previous balance (before the bet) so we
  /// can adjust win chances depending on how risky the bet was.
  /// If the user bets a large fraction of their balance, their chance to win
  /// is reduced linearly up to 50% less chance when they bet their entire balance.
  Future<double> spinWithBet(
    double betAmount,
    double prevBalance,
    Future<void> Function(double) creditCallback,
  ) async {
    if (_isSpinning) return 0.0;
    _isSpinning = true;
    _message = '';
    _winningLines = []; // clear previous combos
    _lastWin = 0.0;
    _isMaxBonus = false;
    notifyListeners();

    // animate (slower)
    const int rounds = 28;
    for (int r = 0; r < rounds; r++) {
      _matrix = List.generate(
        9,
        (_) => SlotItem(SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)]),
      );
      notifyListeners();
      await Future.delayed(Duration(milliseconds: 90 + (r * 10)));
    }

    // Base probabilities (percent out of 100)
    double jackpot = 5.0;
    double triple = 10.0;
    double doubleCombo = 20.0;
    double single = 50.0;

    // Compute stake ratio (0..1). If prevBalance is zero (shouldn't happen) treat as 1.
    final ratio = (prevBalance <= 0) ? 1.0 : (betAmount / prevBalance).clamp(0.0, 1.0);
    // Reduce winning probabilities linearly up to 50% when ratio == 1.0
    final reduction = 0.5 * ratio; // 0..0.5
    jackpot *= (1 - reduction);
    triple *= (1 - reduction);
    doubleCombo *= (1 - reduction);
    single *= (1 - reduction);
    // Recompute loss as remainder to ensure sums to ~100 (implicit)

    // Recalculate thresholds and pick outcome
    final thresholds = <double>[
      jackpot,
      jackpot + triple,
      jackpot + triple + doubleCombo,
      jackpot + triple + doubleCombo + single,
    ];
    final roll = _random.nextDouble() * 100.0;
    double paid = 0.0;

    if (roll < thresholds[0]) {
      // jackpot
      final sym = SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)];
      _matrix = List.generate(9, (_) => SlotItem(sym));
      _winningLines = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6],
      ];
      _isMaxBonus = true;
      final multiplier = 50;
      paid = betAmount * multiplier;
      _lastWin = paid;
      _message = 'JACKPOT!';
      await creditCallback(paid);
    } else if (roll < thresholds[1]) {
      // triple combos
      final sym = SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)];
      _matrix = List.generate(
        9,
        (_) => SlotItem(SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)]),
      );
      final allLines = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6],
      ];
      final toPick = 3;
      final idxs = List<int>.generate(allLines.length, (i) => i)..shuffle(_random);
      for (int i = 0; i < toPick; i++) {
        final l = allLines[idxs[i]];
        for (final pos in l) _matrix[pos] = SlotItem(sym);
        _winningLines.add(l);
      }
      final multiplier = 20;
      paid = betAmount * multiplier;
      _lastWin = paid;
      _message = 'Ganhou! x$multiplier';
      await creditCallback(paid);
    } else if (roll < thresholds[2]) {
      // double combos
      final sym = SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)];
      _matrix = List.generate(
        9,
        (_) => SlotItem(SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)]),
      );
      final allLines = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6],
      ];
      final toPick = 2;
      final idxs = List<int>.generate(allLines.length, (i) => i)..shuffle(_random);
      for (int i = 0; i < toPick; i++) {
        final l = allLines[idxs[i]];
        for (final pos in l) _matrix[pos] = SlotItem(sym);
        _winningLines.add(l);
      }
      final multiplier = 5;
      paid = betAmount * multiplier;
      _lastWin = paid;
      _message = 'Ganhou! x$multiplier';
      await creditCallback(paid);
    } else if (roll < thresholds[3]) {
      // single combo
      final sym = SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)];
      _matrix = List.generate(
        9,
        (_) => SlotItem(SlotSymbol.values[_random.nextInt(SlotSymbol.values.length)]),
      );
      final allLines = [
        [0, 1, 2],
        [3, 4, 5],
        [6, 7, 8],
        [0, 3, 6],
        [1, 4, 7],
        [2, 5, 8],
        [0, 4, 8],
        [2, 4, 6],
      ];
      final toPick = 1;
      final idxs = List<int>.generate(allLines.length, (i) => i)..shuffle(_random);
      for (int i = 0; i < toPick; i++) {
        final l = allLines[idxs[i]];
        for (final pos in l) _matrix[pos] = SlotItem(sym);
        _winningLines.add(l);
      }
      final double multiplier = 1.2;
      paid = betAmount * multiplier;
      _lastWin = paid;
      _message = 'Ganhou! x${multiplier.toStringAsFixed(1)}';
      await creditCallback(paid);
    } else {
      // loss
      _message = 'Perdeu!';
      _winningLines = [];
      _lastWin = 0.0;
    }

    _isSpinning = false;
    notifyListeners();
    return paid;
  }

  // helper methods removed: evaluation is handled inline in spin/spinWithBet
}
