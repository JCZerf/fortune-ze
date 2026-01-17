import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_colors.dart';
import 'viewmodels/account_viewmodel.dart';
import 'viewmodels/slot_viewmodel.dart';
import 'views/account_screen.dart';
import 'views/home_screen.dart';

void main() {
  runApp(const FortuneZeApp());
}

class FortuneZeApp extends StatelessWidget {
  const FortuneZeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AccountViewModel()),
        ChangeNotifierProvider(create: (_) => SlotViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fortune Zé',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: AppColors.gold,
          scaffoldBackgroundColor: AppColors.black,
          colorScheme: const ColorScheme.dark().copyWith(
            primary: AppColors.gold,
            secondary: AppColors.gold,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.gold,
          ),
        ),
        home: const MainScaffold(),
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => MainScaffoldState();
}

class MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  void switchToIndex(int newIndex) => setState(() => _index = newIndex);

  @override
  Widget build(BuildContext context) {
    final pages = [const HomeScreen(), const AccountScreen()];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FORTUNE ZÉ',
          style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        backgroundColor: Colors.black,
        selectedItemColor: const Color(0xFFFFD700),
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Conta'),
        ],
      ),
    );
  }
}
