import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventPage extends StatefulWidget {
  const EventPage({Key? key}) : super(key: key);

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  late TableCalendar _calendarController;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _calendarController = TableCalendar(
      focusedDay: DateTime.now(),
      firstDay: DateTime(2023, 1, 1),
      lastDay: DateTime(2025, 12, 31),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
        });
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getEvents(DateTime day) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('Dates')
        .where('year', isEqualTo: day.year.toString())
        .where('month', isEqualTo: day.month.toString())
        .where('date', isEqualTo: day.day.toString())
        .get();

    return snapshot.docs.map((DocumentSnapshot<Map<String, dynamic>> doc) {
      return doc.data()!;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 0.33 * screenWidth,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 247, 223, 2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
              child: Stack(
                children: [
                  ClipPath(
                    clipper: ArcClipper(),
                    child: Container(
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 247, 223, 2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0.05 * screenWidth,
                    top: 0.1 * screenWidth,
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/images/logo.PNG'),
                      radius: 0.1 * screenWidth,
                    ),
                  ),
                  Positioned(
                    right: 0.15 * screenWidth,
                    top: 0.15 * screenWidth,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 0.5 * screenWidth),
                      child: Text(
                        'Stay On Track With Projects Dates',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 0.04 * screenWidth,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Selected Day: ${_selectedDay.toLocal().toString().split(' ')[0]}',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              child: TableCalendar(
                calendarFormat: _calendarController.calendarFormat,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.white),
                  todayTextStyle: TextStyle(color: Colors.black),
                  markersMaxCount: 5,
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleTextStyle: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                focusedDay: _selectedDay,
                firstDay: DateTime(2023, 1, 1),
                lastDay: DateTime(2025, 12, 31),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                  });
                },
              ),
            ),
            SingleChildScrollView(
              child: FutureBuilder(
                future: _getEvents(_selectedDay),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'No events for the selected day.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> event = snapshot.data![index];
                          return ListTile(
                            title: Text(
                              'Project Name: ${event['projectName']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Start Time: ${event['startTime']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0.0, size.height - 20.0);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 20.0,
    );
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
