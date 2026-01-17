import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../viewmodels/slot_viewmodel.dart';

class SlotView extends StatefulWidget {
  const SlotView({super.key});

  @override
  State<SlotView> createState() => _SlotViewState();
}

class _SlotViewState extends State<SlotView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _audioPlayer;
  bool _listening = false;
  SlotViewModel? _vm;
  bool _disposed = false;
  bool _playedWinSound = false;
  bool _playedFailSound = false;
  bool _isSpinPlaying = false;
  // highlights persist until next bet; no auto-clear timer

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _audioPlayer = AudioPlayer();
    // we will add the vm listener in didChangeDependencies when context is available
  }

  @override
  void dispose() {
    _disposed = true;
    if (_listening && _vm != null) {
      try {
        _vm!.removeListener(_onVmChange);
      } catch (_) {}
    }
    // stop audio (best-effort) and dispose
    try {
      _audioPlayer.stop();
    } catch (_) {}
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listening) {
      _vm = context.read<SlotViewModel>();
      _vm!.addListener(_onVmChange);
      _listening = true;
    }
  }

  void _onVmChange() async {
    // guard against running after dispose
    if (_disposed) return;
    final vm = _vm;
    if (vm == null) return;

    if (vm.isSpinning) {
      // reset per-spin playback flags
      _playedWinSound = false;
      _playedFailSound = false;
      // start the looping spin sound if it's not already playing
      if (!_isSpinPlaying) {
        try {
          await _audioPlayer.setReleaseMode(ReleaseMode.loop);
          if (_disposed) return;
          await _audioPlayer.play(AssetSource('sounds/load.mp3'));
          _isSpinPlaying = true;
        } catch (e) {
          // ignore audio errors; non-critical
        }
      }
    } else {
      // stop the looping spin sound if it was playing
      if (_isSpinPlaying) {
        try {
          await _audioPlayer.stop();
        } catch (_) {}
        _isSpinPlaying = false;
      }
      if (_disposed) return;
      // if there was a win (lastWin > 0) play a short jackpot sound once
      if (vm.lastWin > 0 && !_playedWinSound) {
        try {
          _playedWinSound = true;
          _playOneShot('sounds/jack.mp3');
        } catch (_) {}
      } else if (vm.message.toLowerCase().contains('perde') && !_playedFailSound) {
        // play fail sound once on loss
        try {
          _playedFailSound = true;
          _playOneShot('sounds/fail.mp3');
        } catch (_) {}
      }
    }
  }

  // Play a one-shot sound using a temporary AudioPlayer and dispose it on completion.
  void _playOneShot(String assetPath) async {
    final player = AudioPlayer();
    try {
      await player.setReleaseMode(ReleaseMode.stop);
      if (_disposed) {
        try {
          await player.dispose();
        } catch (_) {}
        return;
      }
      await player.play(AssetSource(assetPath));
      // dispose when finished
      player.onPlayerComplete.listen((_) async {
        try {
          await player.dispose();
        } catch (_) {}
      });
    } catch (_) {
      try {
        await player.dispose();
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SlotViewModel>();

    // highlights now persist until the next bet (winningLines cleared at spin start)

    return Column(
      children: [
        const SizedBox(height: 8),
        // matrix with overlay for winning lines — use measured area + CustomPaint
        LayoutBuilder(
          builder: (context, constraints) {
            // we'll make the matrix square within available width
            final size = constraints.maxWidth;
            return SizedBox(
              width: size,
              height: size,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final t = _controller.value;
                  // gentle rotation and pulsating scale when spinning
                  final angle = vm.isSpinning ? math.sin(t * 2 * math.pi) * 0.06 : 0.0;
                  final scale = vm.isSpinning ? 1.04 + 0.02 * math.sin(t * 2 * math.pi) : 1.0;

                  return Stack(
                    children: [
                      Center(
                        child: Transform.rotate(
                          angle: angle,
                          child: Transform.scale(scale: scale, child: child),
                        ),
                      ),
                      // moving gold shimmer overlay while spinning
                      if (vm.isSpinning)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: 0.18,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment(-1 + 2 * t, -0.3),
                                    end: Alignment(1 + 2 * t, 0.3),
                                    colors: [
                                      Colors.transparent,
                                      AppColors.gold.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                child: Center(child: _buildMatrix(vm)),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Legend bar inside the slot frame — shows victory, bonus amount, or loss
        Builder(
          builder: (context) {
            final msg = vm.message;
            final lower = msg.toLowerCase();
            final isLoss = lower.contains('perde');
            final isJackpot = vm.isMaxBonus || lower.contains('jackpot');
            final money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(vm.lastWin);

            if (msg.isEmpty) return const SizedBox.shrink();

            if (isLoss) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.48),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.red, width: 2),
                ),
                child: Center(
                  child: Text(
                    'PERDEU',
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              );
            }

            // Win / Jackpot
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.deepRed,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gold, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isJackpot ? 'JACKPOT!' : vm.message.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: isJackpot ? 20 : 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ÚLTIMO PREMIO: $money',
                    style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMatrix(SlotViewModel vm) {
    final items = vm.matrix;
    return Column(
      children: [
        for (int row = 0; row < 3; row++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int col = 0; col < 3; col++)
                _cell(items[row * 3 + col].assetName, row * 3 + col, vm),
            ],
          ),
      ],
    );
  }

  // build a golden overlay line for a winning line (expects indices of 3 cells)
  // removed approximate overlay; using painter below for precise strike lines

  Widget _cell(String sym, int idx, SlotViewModel vm) {
    final hasCombos = vm.winningLines.isNotEmpty;
    final matched = hasCombos ? vm.winningLines.any((line) => line.contains(idx)) : false;
    // Normal cell size
    const baseSize = 80.0;
    // When there are combos, non-matching cells shrink by 20%
    final cellSize = hasCombos ? (matched ? baseSize : baseSize * 0.8) : baseSize;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.all(6),
      width: cellSize,
      height: cellSize,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: matched ? AppColors.gold : Colors.grey.shade800,
          width: matched ? 3.5 : 2,
        ),
        boxShadow: matched
            ? [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.24),
                  blurRadius: 12,
                  spreadRadius: 1.5,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          sym,
          style: TextStyle(fontSize: matched ? 30 : 24, color: AppColors.gold),
        ),
      ),
    );
  }
}
