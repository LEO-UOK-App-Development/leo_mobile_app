// ignore_for_file: use_super_parameters, prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({Key? key}) : super(key: key);

  @override
  State<ProjectPage> createState() => ProjectPageState();
}

class ProjectPageState extends State<ProjectPage> {
  Future<QuerySnapshot> _getProjects() async {
    return await FirebaseFirestore.instance
        .collection('Projects')
        .orderBy('timestamp', descending: true)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: screenWidth * 0.33,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 247, 223, 2),
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
                    height: screenHeight * 0.02,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 247, 223, 2),
                    ),
                  ),
                ),
                Positioned(
                  left: 0.05 * screenWidth,
                  top: 0.1 * screenWidth,
                  child: CircleAvatar(
                    backgroundImage: AssetImage('assets/images/download.jpeg'),
                    radius: screenWidth * 0.1,
                  ),
                ),
                Positioned(
                  right: 0.2 * screenWidth,
                  top: 0.15 * screenWidth,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.4,
                    ),
                    child: Text(
                      'Projects Of Leo Club Of UOK',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getProjects(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  List<DocumentSnapshot> projects = snapshot.data!.docs;

                  if (projects.isEmpty) {
                    // Display a message when there are no projects
                    return Center(
                      child: Text('No projects added yet.'),
                    );
                  }
                  return YourBlogContentWidget(projects: projects);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class YourBlogContentWidget extends StatelessWidget {
  final List<DocumentSnapshot> projects;

  YourBlogContentWidget({required this.projects});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        var project = projects[index].data() as Map<String, dynamic>;
        String projectId = projects[index].id;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.network(
                project['image_url'] ?? '',
                height: 300,
                fit: BoxFit.fill,
              ),
              SizedBox(height: 8),
              LearnMoreCaption(projectId, project['caption'] ?? ''),
              Divider(),
            ],
          ),
        );
      },
    );
  }
}

class LearnMoreCaption extends StatefulWidget {
  final String projectId;
  final String caption;

  LearnMoreCaption(this.projectId, this.caption);

  @override
  _LearnMoreCaptionState createState() => _LearnMoreCaptionState();
}

class _LearnMoreCaptionState extends State<LearnMoreCaption> {
  bool showFullCaption = false;
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.caption);
  }

  @override
  Widget build(BuildContext context) {
    String truncatedCaption =
        showFullCaption ? widget.caption : _truncateCaption(widget.caption, 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: widget.projectId));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Project ID copied to clipboard'),
              ),
            );
          },
          child: Text(
            'Project ID: ${widget.projectId}',
            style: TextStyle(
              fontSize: 6,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        Linkify(
          onOpen: (LinkableElement link) async {
            try {
              if (await canLaunch(link.url)) {
                await launch(link.url);
              } else {
                throw 'Could not launch ${link.url}';
              }
            } catch (e) {
              print('Error launching URL: $e');
            }
          },
          text: truncatedCaption,
          style: TextStyle(
            fontSize: 16,
          ),
          linkStyle: TextStyle(
            color: Color.fromARGB(255, 11, 36, 137),
          ),
        ),
        if (showFullCaption)
          TextButton(
            onPressed: () {
              setState(() {
                showFullCaption = false;
                _textEditingController.text = truncatedCaption;
              });
            },
            child: Text(
              'See Less',
              style: TextStyle(
                color: Color.fromARGB(255, 0, 207, 7),
              ),
            ),
          ),
        if (!showFullCaption)
          ElevatedButton(
            onPressed: () {
              setState(() {
                showFullCaption = true;
              });
            },
            child: Text(
              'See More',
              style: TextStyle(
                fontSize: 15,
                color: const Color.fromARGB(255, 0, 207, 7),
              ),
            ),
          ),
      ],
    );
  }

  String _truncateCaption(String caption, int maxWords) {
    List<String> words = caption.split(' ');
    return words.take(maxWords).join(' ');
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
