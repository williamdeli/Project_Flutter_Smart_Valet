import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'gate_page.dart';

class HistoryPage extends StatefulWidget {
  final String username;
  final String email;
  final int saldo;

  const HistoryPage({
    Key? key,
    required this.username,
    required this.email,
    required this.saldo,
  }) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final databaseReference = FirebaseDatabase.instance.reference();

  void HapusData() {
    databaseReference
        .child('akunDummy/${widget.username}/historyPembayaran/')
        .remove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<dynamic>(
          stream: databaseReference
              .child('akunDummy/${widget.username}/historyPembayaran/')
              .onValue,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              List<dynamic> historyData = [];
              DataSnapshot dataValues = snapshot.data.snapshot;
              if (dataValues.value != null) {
                historyData =
                    (dataValues.value as Map<dynamic, dynamic>).values.toList();
              }
              return ListView.builder(
                itemCount: historyData.length,
                itemBuilder: (BuildContext context, int index) {
                  Map<dynamic, dynamic> historyItem =
                      historyData[index] as Map<dynamic, dynamic>;

                  String slot = historyItem['Slot'] as String? ??
                      ''; // Tambahkan pengecekan null dan berikan nilai default jika null

                  return ListTile(
                    title: Text('$historyItem'),
                    trailing: ElevatedButton(
                      child: Text('Gate Page'),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GatePage(
                              slot,
                              widget.saldo,
                              widget.username,
                              widget.email,
                            ),
                          ),
                          (Route<dynamic> route) => false,
                        );
                        print('Tombol diklik pada indeks $index');
                      },
                    ),
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.black,
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: HapusData,
                child: const Text('Clear History'),
              ),
              // Add your other bottom navigation bar items here
            ],
          ),
        ),
      ),
    );
  }
}
