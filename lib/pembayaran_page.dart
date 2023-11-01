import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'gate_page.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:timer_builder/timer_builder.dart';

import 'dashboard_page.dart';

// ignore: must_be_immutable
class PembayaranPage extends StatefulWidget {
  String slot;
  int saldo;
  String username;
  String email;

  PembayaranPage(this.slot, this.saldo, this.username, this.email, {super.key});

  @override
  _PembayaranPageState createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  bool saldoUpdated = false; //biar ga diminesin trus
  final databaseReference = FirebaseDatabase.instance.ref();
  bool isTodaySelected = true;
  DateTime selectedDate = DateTime.now();
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  Timer? countdownTimer;

  Duration myDuration = Duration(seconds: 60);
  @override
  void initState() {
    super.initState();
    countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      if (mounted) {
        // setState(() {
        final seconds = myDuration.inSeconds - 1;
        if (seconds < 0) {
          countdownTimer!.cancel();
          myDuration;

          databaseReference
              .child('parkingArea/${widget.slot}')
              .update({'Status': 'KOSONG'});
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardPage(
                      username: widget.username,
                      email: widget.email,
                      saldo: widget.saldo,
                      slot: widget.slot,
                    )),
            (Route<dynamic> route) => false,
            // ).then((value) {
            //   // Kembali ke halaman sebelumnya (maps) dan memperbarui 'Status' menjadi 'Kosong'
            //   databaseReference
            //                   .child('parkingArea/${widget.slot}')
            //                   .update({'Status': 'TERISI MOBIL'}); //kalo kembbali maka akan bisa dibook oleh orang lain
          );
        } else {
          setState(() {
            myDuration = Duration(
              seconds: seconds,
            );
          });
        }
      } else {
        countdownTimer!.cancel();
        myDuration = Duration(seconds: 60);
      }
      // });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? selectedStartTime ?? TimeOfDay.now()
          : selectedEndTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          selectedStartTime = pickedTime;
        } else {
          selectedEndTime = pickedTime;
        }
      });
    }
  }

  String hitungwaktuBooking() {
    if (selectedStartTime != null && selectedEndTime != null) {
      final startTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedStartTime!.hour,
        selectedStartTime!.minute,
      );
      final endTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedEndTime!.hour,
        selectedEndTime!.minute,
      );

      final duration = endTime.difference(startTime);
      final hours = duration.inHours;

      if (hours < 0) {
        //biar jika diatas jam 12 malem dihitung 1 hari
        final nextDayEndTime = endTime.add(const Duration(days: 1));
        final nextDayDuration = nextDayEndTime.difference(startTime);
        return nextDayDuration.inHours.abs().toString();
      } else {
        final absoluteHours = hours.abs(); //supaya perhitungan tidak minus
        return absoluteHours.toString();
      }
    } else {
      return "-";
    }
  }

  void saveBookingDetailsToFirebase() {
    if (selectedStartTime != null && selectedEndTime != null) {
      final startTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedStartTime!.hour,
        selectedStartTime!.minute,
      );
      final endTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedEndTime!.hour,
        selectedEndTime!.minute,
      );

      //Memeriksa perbedaan antara AM dan PM pada booking duration
      if (selectedStartTime!.period == DayPeriod.am &&
          selectedEndTime!.period == DayPeriod.pm) {
        endTime.add(const Duration(hours: 12));
      }

      final duration = endTime.difference(startTime);
      final hours = duration.inHours;
      final totalHarga = hours.abs() * 5000;
      final bookingDetails = {
        'Date': DateFormat('dd/MM/yyyy').format(selectedDate),
        'Start Time': selectedStartTime!.format(context),
        'End Time': selectedEndTime!.format(context),
        'Total Hour': hitungwaktuBooking(),
        'Total Price': totalHarga,
        'Slot': widget.slot,
      };

      databaseReference
          .child('akunDummy/${widget.username}/saldo')
          .onValue
          .listen((event) {
        if (!saldoUpdated && event.snapshot.value != null) {
          // fungsi !saldoupdated agar tidak terus menerus mengurangi saldo dan event snapshot value agar kejadian ini tidak terjadi ketika saldo dihapus
          int saldo = event.snapshot.value as int;

          if (saldo >= totalHarga && totalHarga != 0) {
            databaseReference
                .child('akunDummy/${widget.username}')
                .update({'saldo': saldo - totalHarga});
            saldoUpdated = true;
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Berhasil Booking'),
                  content: const Text('Silahkan Buka Gate untuk masuk'),
                  actions: [
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        databaseReference
                            .child('parkingArea/${widget.slot}')
                            .update({'Status': 'TERISI MOBIL'});

                        databaseReference
                            .child(
                                'akunDummy/${widget.username}/historyPembayaran/${widget.slot}')
                            .update(bookingDetails);

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GatePage(
                                    widget.slot,
                                    widget.saldo,
                                    widget.username,
                                    widget.email,
                                  )),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Maaf Booking Gagal'),
                  content:
                      const Text('Saldo anda tidak mencukupi untuk booking'),
                  actions: [
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DashboardPage(
                                    username: widget.username,
                                    email: widget.email,
                                    saldo: widget.saldo,
                                    slot: widget.slot,
                                  )),
                          (Route<dynamic> route) =>
                              false, //jika true dia akan ada tanda back dan akan bkin ngebug //udah solve
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pembayaran ${widget.slot}'),
      ),
      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              child: Image.asset(
                'assets/images/car.png',
                width: 400,
                height: 200,
              ),
            ),
            Positioned(
              top: 150,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Row(
                    children: [
                      Radio(
                        value: true,
                        groupValue: isTodaySelected,
                        onChanged: (value) {
                          setState(() {
                            isTodaySelected = value as bool;
                          });
                        },
                      ),
                      const Text('Today'),
                      const SizedBox(width: 20),
                      Radio(
                        value: false,
                        groupValue: isTodaySelected,
                        onChanged: (value) {
                          setState(() {
                            isTodaySelected = value as bool;
                          });
                        },
                      ),
                      const Text('Later'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (isTodaySelected)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10, width: 4),
                        Text(
                          'Selected Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  if (!isTodaySelected)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: const Text('Select Later'),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Selected Date: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                        ),
                      ],
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _selectTime(context, true),
                        child: const Text('Select Start Time'),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Start: ${selectedStartTime != null ? selectedStartTime!.format(context) : "-"}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _selectTime(context, false),
                        child: const Text('Select End Time'),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'End: ${selectedEndTime != null ? selectedEndTime!.format(context) : "-"}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Booking Duration: ${hitungwaktuBooking() != "-" ? "${hitungwaktuBooking()} hours" : ""} x 5000',
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder<dynamic>(
                    stream: databaseReference
                        .child('akunDummy/${widget.username}/saldo')
                        .onValue,
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        var saldoData = snapshot.data!.snapshot.value;
                        int saldo =
                            saldoData != null ? saldoData as int : widget.saldo;

                        return Text('Saldo: $saldo',
                            style: const TextStyle(fontSize: 14));
                      }
                      return Text('Saldo: ${widget.saldo}');
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (hitungwaktuBooking() == "-") {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Masukkan jam yang sesuai'),
                              actions: [
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Menutup dialog
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Booking Details'),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Slot                  : ${widget.slot}',
                                    style: const TextStyle(
                                        fontSize: 20, height: 2),
                                  ),
                                  Text(
                                    'Date                 : ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                                    style: const TextStyle(
                                        fontSize: 20, height: 2),
                                  ),
                                  Text(
                                    'Start Time       : ${selectedStartTime!.format(context)}',
                                    style: const TextStyle(
                                        fontSize: 20, height: 2),
                                  ),
                                  Text(
                                    'End Time         : ${selectedEndTime!.format(context)}',
                                    style: const TextStyle(
                                        fontSize: 20, height: 2),
                                  ),
                                  Text(
                                    'Duration           : ${hitungwaktuBooking()} hours',
                                    style: const TextStyle(
                                        fontSize: 20, height: 2),
                                  ),
                                  Text(
                                    'Total Price       : ${int.parse(hitungwaktuBooking()) * 5000}',
                                    style: const TextStyle(
                                        fontSize: 20, height: 2),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Menutup dialog
                                  },
                                ),
                                TextButton(
                                    child: const Text('Bayar'),
                                    onPressed: () {
                                      saveBookingDetailsToFirebase();
                                    }),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text('Continue'),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Silahkan selesaikan booking dalam ' +
                        myDuration.inSeconds.toString() +
                        ' detik',
                    style: TextStyle(fontSize: 17),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
