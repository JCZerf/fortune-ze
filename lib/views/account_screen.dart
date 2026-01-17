import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../theme/app_colors.dart';
import '../viewmodels/account_viewmodel.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final account = context.watch<AccountViewModel>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    'CONTA',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    color: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.gold, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Saldo atual', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 8),
                          Text(
                            account.balanceFormatted,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'ÚLTIMA CHANCE PIX: ${account.lastPix.isNotEmpty ? account.lastPix : '(nenhuma)'}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  backgroundColor: AppColors.deepRed,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  contentPadding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                                  title: Center(
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundColor: AppColors.gold,
                                          child: Icon(
                                            Icons.account_balance_wallet,
                                            color: AppColors.black,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Saldo insuficiente',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 6),
                                      Text(
                                        'Seu saldo atual é:',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.black,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.gold, width: 1.2),
                                        ),
                                        child: Text(
                                          account.balanceFormatted,
                                          style: const TextStyle(
                                            color: AppColors.gold,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Esse valor é menor que o mínimo necessário para saque. Deseja realizar um depósito agora para continuar?',
                                        style: const TextStyle(color: Colors.white70),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text(
                                        'CANCELAR',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.gold,
                                        foregroundColor: AppColors.black,
                                      ),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        // switch main scaffold to home (index 0)
                                        try {
                                          final ms = context
                                              .findAncestorStateOfType<MainScaffoldState>();
                                          ms?.switchToIndex(0);
                                        } catch (_) {}
                                      },
                                      child: const Text('APOSTAR'),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.black,
                          ),
                          child: const Text('SACAR'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await context.read<AccountViewModel>().depositFixed(50.0);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Depósito de R\$50 efetuado e registrado no histórico',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.black,
                          ),
                          child: const Text('DEPOSITAR R\$50'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Card(
                    color: AppColors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.gold, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Histórico de Depósitos',
                            style: TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          if (account.depositHistory.isEmpty)
                            const Text(
                              '- Sem depósitos registrados',
                              style: TextStyle(color: Colors.white54),
                            )
                          else
                            Column(
                              children: [
                                for (final e in account.depositHistory.reversed)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            e['ts'] != null ? e['ts'].toString() : '-',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'R\$${(e['amount'] as num).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: AppColors.gold,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const Divider(color: Colors.white12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total depositado',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    Text(
                                      account.totalDepositedFormatted,
                                      style: const TextStyle(
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const _DevSignature(),
        ],
      ),
    );
  }
}

// small signature: developer credit
class _DevSignature extends StatelessWidget {
  const _DevSignature();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 12.0, bottom: 6.0),
      child: Center(
        child: Text(
          'developby jcarlosleite',
          style: TextStyle(color: Colors.white24, fontSize: 11),
        ),
      ),
    );
  }
}
