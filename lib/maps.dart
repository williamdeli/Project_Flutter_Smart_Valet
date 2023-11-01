import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pembayaran_page.dart';

class MapsPage extends StatefulWidget {
  final int saldo;
  final String username;
  final String email;


  const MapsPage({
    super.key,
    required this.saldo,
    required this.username,
    required this.email,

  });

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final databaseReference = FirebaseDatabase.instance.ref();

  @override
  void dispose() {
    super.dispose();
    // Dispose any active listeners or resources here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Tempat Parkir di Blok A',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Hello ${widget.username}, untuk pesan tempat parkir yang diinginkan silahkan klik icon dibawah ini',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              //tidak pake column terjadi flex dart(render flex) exception error
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 4; i++)
                  Expanded(
                    //jika tidak dibalut expanded akan overflow ke kanan 135 pixels
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: statusParkir(
                        slot: 'SLOT_$i',
                        username: widget.username,
                        saldo: widget.saldo,
                        email: widget.email,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 5; i <= 8; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: statusParkir(
                        slot: 'SLOT_$i',
                        username: widget.username,
                        saldo: widget.saldo,
                        email: widget.email,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: camel_case_types
class statusParkir extends StatefulWidget {
  final String slot;
  final String username;
  final int saldo;
  final String email;

  const statusParkir({
    required this.slot,
    required this.username,
    required this.saldo,
    required this.email,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _statusParkirState createState() => _statusParkirState();
}

// ignore: camel_case_types
class _statusParkirState extends State<statusParkir> {
  late DatabaseReference
      _databaseReference; //pake late karena null safety, deklarasi tanpa kasih nilai awal
  Color _widgetColor = Colors.green;
  StreamSubscription<dynamic>? _statusSubscription; //butuh lib import async
  //stream digunakan untuk mantau perubahan status parkir yang dikirim oleh firebase

  @override
  void initState() {
    super.initState();
    _databaseReference = FirebaseDatabase.instance
        .ref()
        .child('parkingArea')
        .child(widget.slot)
        .child('Status');

    _statusSubscription = _databaseReference.onValue.listen((event) {
      //statussubcription adalah stream yang akan di listen
      if (mounted) {
        //untuk menghindari memory leak ketika widget di dispose tapi masih ada stream yang aktif
        //mengurangi potensi menyebabkan bug ketika pindah halaman
        setState(() {
          if (event.snapshot.value == 'TERISI MOBIL') {
            _widgetColor = Colors.red;
          } else {
            _widgetColor = Colors.green;
          }
        });
      }
    }); //butuh lib async
  }

  @override
  void dispose() {
    //menghindari masalah jangka panjang ketika widget di dispose tapi masih ada stream yang aktif
    _statusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            if (_widgetColor == Colors.red) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Slot Sedang Terisi'),
                    content: const Text('Pilih slot lain yang kosong'),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop(); // Menutup dialog
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              final DatabaseReference statusRef = FirebaseDatabase.instance
                  .ref('parkingArea/${widget.slot}/Status');
              statusRef.set('TERISI MOBIL');
              // Berpindah ke halaman pembayaran
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PembayaranPage(
                    widget.slot,
                    widget.saldo,
                    widget.username,
                    widget.email,
                  ),
                ),
              ).then((value) async {
                // Kembali ke halaman sebelumnya (maps) dan memperbarui 'Status' menjadi 'Kosong'
                final DatabaseReference statusRef = FirebaseDatabase.instance
                    .ref('parkingArea/${widget.slot}/Status');
                await statusRef.set(
                    'Kosong'); //kalo kembbali maka akan bisa dibook oleh orang lain
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _widgetColor,
          ),
          child: SizedBox(
            width: 80,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                color: _widgetColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.directions_car,
                    color: Colors.black,
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.slot,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12, //untuk mengatur tulisan slot
                      height: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _widgetColor == Colors.red ? 'Ada Mobil' : 'Kosong',
          style: TextStyle(
            color: _widgetColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
