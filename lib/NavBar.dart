import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uokleo/screens/SignIn.dart';
import 'package:uokleo/screens/admin.dart';
import 'package:uokleo/screens/board.dart';
import './screens/EventPage.dart';
import './screens/BlogPage.dart';
import './screens/Projects.dart';

class NavBar extends StatefulWidget {
  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    BlogPage(),
    ProjectPage(),
    EventPage(),
    BoardPage(),
    AdminPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black26,
          backgroundColor:
              Color.fromARGB(255, 247, 223, 2), // Set the background color here
          elevation: 0, // Set elevation to 0
          onTap: (index) {
            if (index == 5) {
              // Logout action
              _signOut(context);
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: buildIconWithBox(Icons.article_outlined, 0),
              label: 'Blogs',
              backgroundColor: Color.fromARGB(255, 247, 223, 2),
            ),
            BottomNavigationBarItem(
              icon: buildIconWithBox(Icons.work_outline_rounded, 1),
              label: 'Projects',
              backgroundColor: Color.fromARGB(255, 247, 223, 2),
            ),
            BottomNavigationBarItem(
              icon: buildIconWithBox(Icons.calendar_today, 2),
              label: 'Dates',
              backgroundColor: Color.fromARGB(255, 247, 223, 2),
            ),
            BottomNavigationBarItem(
              icon: buildIconWithBox(Icons.admin_panel_settings_outlined, 3),
              label: 'Admin',
              backgroundColor: Color.fromARGB(255, 247, 223, 2),
            ),
            BottomNavigationBarItem(
              icon: buildIconWithBox(Icons.people_alt_outlined, 4),
              label: 'board',
              backgroundColor: Color.fromARGB(255, 247, 223, 2),
            ),
            BottomNavigationBarItem(
              icon: buildIconWithBox(Icons.logout, 5),
              label: 'Logout',
              backgroundColor: Color.fromARGB(255, 247, 223, 2),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    bool confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      } catch (e) {
        print('Error during sign out: $e');
      }
    }
  }

  Widget buildIconWithBox(IconData icon, int index) {
    return Container(
      width: 60,
      height: 40,
      decoration: BoxDecoration(
        color: _currentIndex == index
            ? Color.fromARGB(255, 251, 249, 249)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 28,
          color: _currentIndex == index
              ? const Color.fromARGB(255, 67, 163, 71)
              : const Color.fromARGB(255, 10, 0, 0),
        ),
      ),
    );
  }
}
