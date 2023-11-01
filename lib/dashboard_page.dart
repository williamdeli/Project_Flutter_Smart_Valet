import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'history_page.dart';
import 'maps.dart';

class DashboardPage extends StatefulWidget {
  final String email;
  final int saldo;
  final String username;
  final String slot;

  const DashboardPage({
    super.key,
    required this.email,
    required this.saldo,
    required this.username,
    required this.slot,
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final databaseReference = FirebaseDatabase.instance.ref();
  bool tombolTopup = false;
  int _currentIndex = 0;

  void _topUp() {
    int saldo = widget.saldo;
    if (tombolTopup == false) {
      String username = widget.username;

      databaseReference
          .child('akunDummy/$username')
          .update({'saldo': saldo + 15000}).then((_) {
        // then menandakan bahwa proses update saldo telah selesai
        // (_) fungsi callback, untuk melakukan tindakan lanjutan setelah proses update selesai
        setState(() {
          tombolTopup = true;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sukses'),
              content: const Text('Saldo telah ditambahkan.'),
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
      }).onError((error, stackTrace) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Gagal menambahkan saldo.'),
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
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Peringatan'),
            content: const Text(
                'Saldo hanya dapat ditambahkan sekali setiap login.'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex ==
                0 //menampilkan appbar sesuai dengan index yang dipilih pada bottom navigation bar (dashboard, maps, history)
            ? 'Dashboard' //jika index 0, maka judulnya dashboard, jika index 1, maka judulnya maps, jika index bukan 0 atau 1, mis: 2 maka judulnya history
            : _currentIndex == 1
                ? 'Maps'
                : 'History'),
      ),
      body: Stack(
        children: [
          Offstage(
            offstage: _currentIndex !=
                0, //jika index tidak sama dengan 0, maka singlechild dan column akan ditampilkan
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FloatingActionButton(
                          onPressed: _topUp,
                          tooltip: 'Top Up',
                          backgroundColor: Colors.grey[800],
                          child: const Text(
                            'Top Up',
                            style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                            ),
                            selectionColor: Colors.white,
                          ),
                        ),
                        StreamBuilder<dynamic>(
                          stream: databaseReference
                              .child('akunDummy/${widget.username}/saldo')
                              .onValue,
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (snapshot.hasData) {
                              var saldoData = snapshot.data!.snapshot.value;
                              int saldo = saldoData != null
                                  ? saldoData as int
                                  : widget.saldo;
                              return Text(
                                'Saldo: $saldo',
                                style: const TextStyle(fontSize: 18),
                              );
                            }
                            return Text('Saldo: ${widget.saldo}');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/images/dashboard.png',
                      width: 400,
                      height: 200,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Hello ${widget.username},',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      'Email: ${widget.email}',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: const Text(
                      'Silahkan ke MAPS untuk mencari tempat',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(5.0),
                    child: const Text(
                      'Temukan Tempat Kesayanganmu',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      },
                      child: const Text('Keluar dari Akun'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Offstage(
            // untuk mengatur offstage dari maps dan history page (agar tidak tampil bersamaan dengan dashboard)
            offstage: _currentIndex !=
                1, // jika index dari bottom navigation bar bukan 1 maka offstage akan true sehingga hal maps tidak ditampilkan
            child: MapsPage(
              //tapi jika index dari bottom navigation bar adalah 1 maka offstage akan false sehingga hal maps ditampilkan

              username: widget.username,
              saldo: widget.saldo,
              email: widget.email,
            ),
          ),
          Offstage(
            offstage: _currentIndex != 2,
            child: HistoryPage(
              username: widget.username,
              saldo: widget.saldo,
              email: widget.email,
              // slot: widget.slot,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex:
            _currentIndex, // untuk mengatur index dari bottom navigation bar
        onTap:
            _onTabTapped, // untuk mengatur navigasi bawah (dashboard, maps, history)
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }

  void _onTabTapped(int index) {
    // untuk navigasi bawah (dashboard, maps, history)
    setState(() {
      // untuk mengubah state dari widget
      _currentIndex = index; // untuk mengubah index dari bottom navigation bar
    });
  }
}
