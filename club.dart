// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uni_club/profile.dart';


final User? useruid = FirebaseAuth.instance.currentUser;
final useruiddd = useruid!.uid;
final useriemaillll = useruid!.email;

class Club {
  final String id;
  final String name;
  final String description;

  Club({required this.id, required this.name, required this.description});
}

class Event {
  final String title;
  final String eventDate;
  final String description;

  Event({
    required this.title,
    required this.eventDate,
    required this.description,
  });
}

class ClubListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Club List'),
        leading: IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );  },),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clubs').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final clubDocs = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            itemCount: clubDocs.length,
            itemBuilder: (context, index) {
              var clubData = clubDocs[index].data() as Map<String, dynamic>;
              Club club = Club(
                id: clubDocs[index].id,
                name: clubData['name'],
                description: clubData['description'],
              );

              return InkWell(
                onTap: () {
                  _navigateToClubDetailPage(context, club);
                },
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          club.description,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToClubDetailPage(BuildContext context, Club club) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClubDetailPage(club: club),
      ),
    );
  }
}

class News {
  final String title;
  final String content;

  News({required this.title, required this.content});
}

class EventsListPage extends StatelessWidget {
  final String clubId;

  EventsListPage({required this.clubId, Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').where('club_id', isEqualTo: clubId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final eventDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: eventDocs.length,
            itemBuilder: (context, index) {
              var event = eventDocs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(event['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event Date: ${event['eventDate']}'),
                    Text('Description: ${event['description']}'),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventPage(clubId: clubId)),
          );
        },
        tooltip: 'Add Events',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddEventPage extends StatelessWidget {
  final String clubId;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _eventDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  AddEventPage({required this.clubId, Key? key});

  Future<void> _addEvent(BuildContext context) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(useruiddd).get();
    if (userDoc.exists && userDoc['canpost'] == 'YES') {
    try {
      String title = _titleController.text;
      String eventDate = _eventDateController.text;
      String description = _descriptionController.text;

      await FirebaseFirestore.instance.collection('events').add({
        'title': title,
        'eventDate': eventDate,
        'description': description,
        'club_id': clubId,  // Store the club ID
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error adding event: $e');
    }}
    else{
    print('this user cant post');
    Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _eventDateController,
              decoration: const InputDecoration(labelText: 'Event Date'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addEvent(context),
              child: const Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsListPage extends StatelessWidget {
  final String clubId;

  NewsListPage({required this.clubId, Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('news').where('club_id', isEqualTo: clubId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final newsDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: newsDocs.length,
            itemBuilder: (context, index) {
              var news = newsDocs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(news['title']),
                subtitle: Text(news['content']),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNewsPage(clubId: clubId)),
          );
        },
        tooltip: 'Add News',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddNewsPage extends StatelessWidget {
  final String clubId;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  AddNewsPage({required this.clubId, Key? key});

  Future<void> _addNews(BuildContext context) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(useruiddd).get();
    if (userDoc.exists && userDoc['canpost'] == 'YES') {
    try {
      String title = _titleController.text;
      String content = _contentController.text;

      await FirebaseFirestore.instance.collection('news').add({
        'title': title,
        'content': content,
        'club_id': clubId,  // Store the club ID
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error adding news: $e');
    }}
    else {print('this user cant post');
    Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add News'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addNews(context),
              child: const Text('Add News'),
            ),
          ],
        ),
      ),
    );
  }
}

class ClubDetailPage extends StatefulWidget {
  final Club club;

  const ClubDetailPage({Key? key, required this.club});

  @override
  _ClubDetailPageState createState() => _ClubDetailPageState();
}

class _ClubDetailPageState extends State<ClubDetailPage> {
  bool isJoined = false;
  bool hasRequestedJoin = false;


  void _toggleJoinStatus(Club club) async {
    String userId = useruiddd; // Replace with actual user ID
    String? useremail = useriemaillll;
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    try {
      DocumentSnapshot userDoc = await users.doc(userId).get();

      if (userDoc.exists) {
        if (isJoined) {
        // User is already joined
        setState(() {
          isJoined = false;
        });
        print('User left the club: ${club.name}');
      } else {
        // User is not joined, send a join request
        // Assuming club_join_request has the structure: club_id, user_id, user_email, user_name
        await FirebaseFirestore.instance.collection('club_join_request').add({
          'club_id': club.id,
          'user_id': userId,
          'user_email': useremail,
          'user_name': userDoc['name'], // Use user's display name if available
        });

        setState(() {
          hasRequestedJoin = true;
        });

        print('Join request sent for ${club.name}');
      }
      } else {
        print('User not found in Firestore');
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Check if the user is already joined when the widget is initialized
    // This assumes you have the logic to determine if the user is joined in your app
    // Modify this according to how you track user's joined clubs
    _checkIfUserIsJoined(widget.club.id);

  }

Future<void> _checkIfUserIsJoined(String clubId) async {
    String userId = useruiddd;

    // Fetch the user's document from Firestore
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userDocSnapshot = await userDocRef.get();

    if (userDocSnapshot.exists) {
      List<dynamic> joinedClubs = userDocSnapshot['joined_clubs'];
        setState(() {
           isJoined = joinedClubs.contains(clubId);
        });
        } 
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.club.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.club.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              widget.club.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 400),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _navigateToEventsPage(context, widget.club);
                  },
                  child: const Text('Events'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _toggleJoinStatus(widget.club);
                  },
                  child: Text(isJoined
                   ? 'Joined' 
                   : (hasRequestedJoin ? 'Join Request Sent' : 'Join'))
                ),
                ElevatedButton(
                  onPressed: () {
                    _navigateToNewsPage(context, widget.club);
                  },
                  child: const Text('News'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEventsPage(BuildContext context, Club club) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventsListPage(clubId: club.id)),
    );
  }

  void _navigateToNewsPage(BuildContext context, Club club) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewsListPage(clubId: club.id)),
    );
  }
}