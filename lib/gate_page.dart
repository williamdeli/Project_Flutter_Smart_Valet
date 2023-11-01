import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_firebase/dashboard_page.dart';

class GatePage extends StatefulWidget {
  final String slot;
  final int saldo;
  final String username;
  final String email;

  const GatePage(this.slot, this.saldo, this.username, this.email, {super.key});

  @override
  _GatePageState createState() => _GatePageState();
}

class _GatePageState extends State<GatePage> {
  final databaseReference = FirebaseDatabase.instance.ref( );

  late DatabaseReference _gateReference;
  var _gateStatus = 'FALSE';
  var _bukaGateCount = 0;
  var _tutupGateCount = 0;

  @override
  void initState() {
    super.initState();
    initializeGate();
  }

  void initializeGate() {
    _gateReference = FirebaseDatabase.instance
        .ref()
        .child('parkingArea')
        .child(widget.slot)
        .child('Gate');

    _gateReference.onValue.listen((event) {
      final snapshot = event.snapshot;
      setState(() {
        _gateStatus = snapshot.value as String? ?? 'FALSE';
      });
    });
  }

  void _toggleGateStatus(String newStatus) {
    try {
      _gateReference.set(newStatus);

      setState(() {
        _gateStatus = newStatus;
      });

      if (newStatus == 'TRUE') {
        _bukaGateCount++;
        if (_bukaGateCount >= 4) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
        }
      } else {
        _tutupGateCount++;
        if (_tutupGateCount >= 4) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
          );
        }
      }
    } catch (e, stackTrace) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Terjadi kesalahan: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      print('Error: $e\n$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gate ${widget.slot}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gate ${widget.slot}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Username ${widget.username}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<DataSnapshot>(
              stream: databaseReference
                  .child('akunDummy/${widget.username}/saldo')
                  .onValue
                  .map((event) => event.snapshot),
              builder:
                  (BuildContext context, AsyncSnapshot<DataSnapshot> snapshot) {
                if (snapshot.hasData) {
                  var saldoData = snapshot.data!.value;
                  int saldo =
                      saldoData != null ? saldoData as int : widget.saldo;
                  return Text('Saldo: $saldo',
                      style: const TextStyle(fontSize: 18));
                } else if (snapshot.hasError) {
                  // Handle the error case
                  return Text('Error: ${snapshot.error}');
                }
                return Text('Saldo: ${widget.saldo}');
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'PERINGATAN!!!',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              'Jika Buka/Tutup gate lebih dari 3x,',
              style: TextStyle(fontSize: 18),
            ),
            const Text(
              'sesi akan berakhir',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Buka gate: $_bukaGateCount x',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Tutup gate: $_tutupGateCount x',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Status Gate: ${_gateStatus == 'TRUE' ? 'Terbuka' : 'Tertutup'}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Konfirmasi'),
                      content:
                          const Text('Apakah Anda yakin untuk membuka gate?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _toggleGateStatus('TRUE');
                          },
                          child: const Text('Ya'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Buka Gate'),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Konfirmasi'),
                      content:
                          const Text('Apakah Anda yakin untuk menutup gate?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _toggleGateStatus('FALSE');
                          },
                          child: const Text('Ya'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text('Tutup Gate'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DashboardPage(
                      username: widget.username,
                      email: widget.email,
                      saldo: widget.saldo,
                      slot: widget.slot,
                    ),
                  ),
                  (_) => false,
                );
              },
              child: const Text('EXIT to Dashboard'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Butuh bantuan ?? Hubungi CS kami ',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<DatabaseReference>(
        '_gateReference', _gateReference));
  }
}
