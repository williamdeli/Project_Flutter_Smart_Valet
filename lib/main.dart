import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_page.dart';
import 'create_account_page.dart';
import 'dashboard_page.dart';
import 'maps.dart';
import 'history_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/createAccount': (context) => const CreateAccountPage(),
        '/dashboard': (context) {
          Map<String, dynamic>? arguments = ModalRoute.of(context)
              ?.settings
              .arguments as Map<String, dynamic>?;
          return DashboardPage(
            username: arguments?['username'] ?? '',
            email: arguments?['email'] ?? '',
            saldo: arguments?['saldo'] ?? 0,
            slot: arguments?['slot'] ?? '',
          );
        },
        '/login': (context) => const LoginPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const LoginPage());
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/maps') {
          Map<String, dynamic>? arguments =
              settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => MapsPage(
              username: arguments?['username'] ?? '',
              saldo: arguments?['saldo'] ?? 0,
              email: arguments?['email'] ?? '',
            ),
          );
        } else if (settings.name == '/setting') {
          Map<String, dynamic>? arguments =
              settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => HistoryPage(
              username: arguments?['username'] ?? '',
              email: arguments?['email'] ?? '',
              saldo: arguments?['saldo'] ?? 0,
              // slot: arguments?['slot'] ?? '',
            ),
          );
        }
        return MaterialPageRoute(builder: (context) => const LoginPage());
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'login_page.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Your App',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: LoginPage(),
//     );
//   }
// }
