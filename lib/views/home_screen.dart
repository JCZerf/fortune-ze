import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../viewmodels/account_viewmodel.dart';
import '../viewmodels/slot_viewmodel.dart';
import 'slot_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _bet = 1.0;

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountViewModel>();
    final slotVm = context.watch<SlotViewModel>();

    final max = account.balance > 1.0 ? account.balance : 1.0;

    // ensure _bet is within range
    if (_bet > max) _bet = max;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),

          // header removed to save space per user request

          // Slot machine area with side payline numbers and gold frame
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700), // outer gold frame
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)],
              ),
              padding: const EdgeInsets.all(6),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.deepRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // left paylines
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '1',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '2',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '3',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // center matrix
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const SlotView(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // right paylines (mirror)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '1',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '2',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            '3',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'developby jcarlosleite',
              style: TextStyle(color: Colors.white24, fontSize: 11),
            ),
          ),

          const SizedBox(height: 16),

          // Removed duplicate purple PRÊMIO bar per user request; only the red ÚLTIMO PREMIO remains below.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold, width: 2),
                boxShadow: [
                  BoxShadow(color: AppColors.grayShadow.withOpacity(0.25), blurRadius: 6),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'ÚLTIMO PREMIO',
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        slotVm.lastWin > 0 ? 'R\$${slotVm.lastWin.toStringAsFixed(2)}' : 'R\$0,00',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('CONTA', style: TextStyle(color: AppColors.gold, fontSize: 12)),
                        Text(
                          context.watch<AccountViewModel>().balanceFormatted,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bet controls
          Card(
            color: AppColors.black,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.gold, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Slider(
                    min: 1.0,
                    max: max,
                    value: _bet.clamp(1.0, max),
                    activeColor: AppColors.gold,
                    inactiveColor: Colors.grey.shade700,
                    label: 'Aposta: R\$${_bet.toStringAsFixed(2)}',
                    onChanged: account.balance > 0 && !slotVm.isSpinning
                        ? (v) => setState(() => _bet = v)
                        : null,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _bet <= 1.0
                        ? 'Aposta mínima: R\$${_bet.toStringAsFixed(2)}'
                        : 'Aposta atual: R\$${_bet.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: account.balance <= 0 || slotVm.isSpinning
                            ? null
                            : () async {
                                final prev = await account.tryPlaceBet(_bet);
                                if (prev == null) return;
                                await slotVm.spinWithBet(_bet, prev, (won) => account.credit(won));
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black,
                          foregroundColor: AppColors.gold,
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        ),
                        child: const Text(
                          'APOSTAR',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => setState(() => _bet = max),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.gold),
                          foregroundColor: AppColors.gold,
                          backgroundColor: AppColors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        ),
                        child: const Text('MAX'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Matrix rendering moved to SlotView; helpers removed.
}
