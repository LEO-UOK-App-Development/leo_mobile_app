// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({Key? key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
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
                      'LEO CLUB OF UNIVERSITY OF KALANIYA',
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
          Expanded(
            child: YourBlogContentWidget(),
          ),
        ],
      ),
    );
  }
}

class YourBlogContentWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Blogs')
          .orderBy('timestamp',
              descending: true) // Order by timestamp in descending order
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> blogs = snapshot.data?.docs ?? [];

        if (blogs.isEmpty) {
          return Center(child: Text('No blogs added yet.'));
        }

        return ListView.builder(
          itemCount: blogs.length,
          itemBuilder: (context, index) {
            // Extracting data from Firestore
            var blogData = blogs[index].data() as Map<String, dynamic>;
            String blogTitle = blogData['title'] ?? '';
            String blogText = blogData['long_caption'] ?? '';
            String imagePath = blogData['image_url'] ?? '';

            return BlogItemWidget(blogText, imagePath, blogTitle);
          },
        );
      },
    );
  }
}

class BlogItemWidget extends StatelessWidget {
  final String blogText;
  final String imagePath;
  final String blogTitle;

  BlogItemWidget(this.blogText, this.imagePath, this.blogTitle);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(0.02 * screenWidth),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                imagePath,
                height: 280,
                fit: BoxFit.fill,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: .04 * screenWidth,
                  vertical: 10,
                ),
                child: SelectableText(
                  // Wrap with SelectableText
                  blogTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 0.05 * screenWidth,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(0.04 * screenWidth),
                child: Text(
                  blogText,
                  maxLines: 2, // Display only 2 lines initially
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showLearnMoreDialog(context, blogText);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 23, 187, 29)),
                    child: Text(
                      'Learn more',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLearnMoreDialog(BuildContext context, String blogText) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: SelectableText(blogTitle), // Wrap with SelectableText
          content: SingleChildScrollView(
            child: Text(blogText),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 2, size.height + 20, size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
