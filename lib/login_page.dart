import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final databaseReference = FirebaseDatabase.instance.ref();

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _Peringatan('GAGAL', 'Username/password harus diisi.');
      return;
    }

    // Mendapatkan data dari Firebase Realtime Database
    try {
      //try and catch untuk menangkap error
      //print("snapshot");
      DatabaseEvent event =
          await databaseReference.child('akunDummy/$username').once();
      DataSnapshot snapshot = event.snapshot;
      // print("test");

      if (snapshot.value != null) {
        //ngecek apakah ada data atau tidak
        Map<dynamic, dynamic> dataakun =
            snapshot.value as Map<dynamic, dynamic>;
        String usernameDatabase = dataakun['username']
            as dynamic; // untuk menyimpan username yang ada di database
        String passwordDatabase = dataakun['password']
            as dynamic; // untuk menyimpan password yang ada di database

        // Memeriksa username dan password yang dimasukkan
        if (username == usernameDatabase && password == passwordDatabase) {
          _keDashboard(username, dataakun['email'], dataakun['saldo']);
        } else {
          _Peringatan('Error', 'Username/password yang Anda masukkan salah.');
        }
      } else {
        _Peringatan('Error', 'Akun tidak ditemukan.');
      }
    } catch (error, stackTrace) {
      _throw(error, stackTrace);
    }
  }

  void _keDashboard(
    String username,
    String email,
    int saldo,
  ) {
    Navigator.of(context).pushReplacementNamed('/dashboard', arguments: {
      'username': username,
      'email': email,
      'saldo': saldo,
    });
  }

  void _Peringatan(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _keCreateAcc() {
    Navigator.of(context).pushNamed('/createAccount');
  }

  external static Never _throw(Object error, StackTrace stackTrace);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Image.asset(
            //   'assets/images/car_log.gif',
            //   width: 20,
            //   height: 150,
            // ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: _keCreateAcc,
              child: const Text('Create Account'),
            ),
            // Image.asset(
            //   'assets/images/car_log.gif',
            //   width: 20,
            //   height: 150,
            // ),
          ],
        ),
      ),
    );
  }
}
