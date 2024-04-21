import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myproject/login.dart';
import 'package:myproject/userprofile.dart';
import 'package:myproject/src/rateus.dart';
import 'home.dart';

class CustomDrawer extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final menuItems = [
    MenuItem(icon: Icons.person, text: 'Profile', action: UserProfile()),
    MenuItem(icon: Icons.home, text: 'Home', action: Home()),
    MenuItem(icon: Icons.star, text: 'Rate Us', action: RateUs()),
    MenuItem(icon: Icons.logout, text: 'Logout', action: LogIn()),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<DocumentSnapshot?>(
              future: _getUserProfileData(),
              builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return _buildErrorHeader();
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    DocumentSnapshot? data = snapshot.data;
                    if (data!.exists) {
                      String name = data.get('name') ?? 'User Profile';
                      String email = data.get('email') ?? 'user@example.com';
                      String imageUrl = data.get('imageUrl') ?? '';
                      return UserAccountsDrawerHeader(
                        accountName: Text('Hello, ' + name, style: TextStyle(color: Colors.white)),
                        accountEmail: Text(email, style: TextStyle(color: Colors.white)),
                        currentAccountPicture: CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                          child: imageUrl.isEmpty ? Text(name[0], style: TextStyle(color: Colors.black)) : null,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
                      );
                    } else {
                      // Data does not exist in Firebase
                      return _buildNoDataHeader();
                    }
                  } else {
                    return _buildErrorHeader();
                  }
                } else {
                  return _buildLoadingHeader();
                }
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return buildListTile(
                  leading: Icon(menuItems[index].icon, color: Colors.white),
                  title: Text(menuItems[index].text, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  onTap: () {
                    _navigateToMenuItem(context, menuItems[index].action);
                  },
                );
              },
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: buildListTile(
                leading: const Icon(Icons.help, color: Colors.white),
                title: const Text('Help', style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  // Add your help navigation logic here
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListTile({required Widget leading, required Widget title, required VoidCallback onTap}) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        leading: IconTheme(
          data: const IconThemeData(color: Colors.white),
          child: leading,
        ),
        title: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: title,
        ),
        onTap: onTap,
      ),
    );
  }

  Future<DocumentSnapshot?> _getUserProfileData() async {
    try {
      if (_auth.currentUser != null) {
        CollectionReference users = FirebaseFirestore.instance.collection('users');
        DocumentSnapshot docSnapshot = await users.doc(_auth.currentUser!.uid).get();
        if (docSnapshot.exists) {
          Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
          if (!data.containsKey('name')) {
            throw Exception('Name not found in user profile data');
          }
        } else {
          throw Exception('User profile data does not exist');
        }
        return docSnapshot;
      } else {
        throw Exception('User not logged in');
      }
    } catch (e) {
      print('Error fetching user profile data: $e');
      return null;
    }
  }


  void _navigateToMenuItem(BuildContext context, Widget action) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => action),
      );
    } catch (e) {
      print('Error navigating to menu item: $e');
    }
  }

  Widget _buildNoDataHeader() {
    return UserAccountsDrawerHeader(
      accountName: const Text('No Data', style: TextStyle(color: Colors.white)),
      accountEmail: const Text('No data available', style: TextStyle(color: Colors.white)),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.info, color: Colors.black),
      ),
      decoration: BoxDecoration(
        color: Colors.black,
      ),
    );
  }

  Widget _buildLoadingHeader() {
    return UserAccountsDrawerHeader(
      accountName: const Text('Loading...', style: TextStyle(color: Colors.white)),
      accountEmail: const Text('Loading...', style: TextStyle(color: Colors.white)),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: Colors.white,
        child: CircularProgressIndicator(),
      ),
      decoration: BoxDecoration(
        color: Colors.black,
      ),
    );
  }

  Widget _buildErrorHeader() {
    return UserAccountsDrawerHeader(
      accountName: const Text('Error', style: TextStyle(color: Colors.white)),
      accountEmail: const Text('Error fetching data', style: TextStyle(color: Colors.white)),
      currentAccountPicture: const CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.error, color: Colors.black),
      ),
      decoration: BoxDecoration(
        color: Colors.black,
      ),
    );
  }
}

class MenuItem {
  final IconData icon;
  final String text;
  final Widget action;

  MenuItem({required this.icon, required this.text, required this.action});
}
