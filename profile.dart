import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _userName = '';
  String _userId = '';
  List<String> _joinedClubIds = [];
  List<String> _joinedClubNames = [];

  Future<void> _fetchUserData() async {
    // Get the current user's UID from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      // Fetch user data from Firestore using the UID
      try {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(userId).get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc['name']; // Replace with your field names
            _userId = userDoc['id']; // Replace with your field names
            _joinedClubIds = List<String>.from(userDoc['joined_clubs']);
          });

          // Fetch joined club names
          _fetchJoinedClubNames();
        } else {
          print('Document does not exist for UID: $userId');
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
  }

  Future<void> _fetchJoinedClubNames() async {
    for (String clubId in _joinedClubIds) {
      try {
        DocumentSnapshot clubDoc =
            await FirebaseFirestore.instance.collection('clubs').doc(clubId).get();

        if (clubDoc.exists) {
          setState(() {
            _joinedClubNames.add(clubDoc['name']);
          });
        } else {
          print('Club document does not exist for club ID: $clubId');
        }
      } catch (e) {
        print('Error fetching club data: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$_userName',
            style: TextStyle(fontSize: 18),),
            Text('$_userId'),
            const SizedBox(height: 20),
            Text('Joined Clubs:'),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _joinedClubNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_joinedClubNames[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
