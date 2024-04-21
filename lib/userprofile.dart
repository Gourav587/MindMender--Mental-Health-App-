import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

enum Gender { Male, Female, Other }

class _UserProfileState extends State<UserProfile> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  Map<String, dynamic> _profile = {};
  File? _imageFile;
  Gender? _selectedGender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    setState(() {
      _isLoading = true;
    });
    _user = _auth.currentUser;
    if (_user == null) {
      // create a guest user
      _user = (await _auth.signInAnonymously()).user;
    }
    await _loadUserProfile();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUserProfile() async {
    if (_user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        setState(() {
          _profile = doc.data() as Map<String, dynamic>;
        });
      } else {
        // Initialize _profile with empty values
        setState(() {
          _profile = {
            'firstName': '',
            'lastName': '',
            'email': '',
            'phoneNumber': '',
            'age': '',
            'weight': '',
            'gender': '',
          };
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _imageFile = File(photo!.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      setState(() {
        _imageFile = File(photo!.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to take photo: $e')));
    }
  }

  Future<void> _saveUserProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState!.save();
      try {
        // upload image to Firebase Storage
        if (_imageFile != null) {
          TaskSnapshot snapshot = await _storage.ref('users/${_user!.uid}/profile.jpg').putFile(_imageFile!);
          String downloadUrl = await snapshot.ref.getDownloadURL();
          _profile['photoUrl'] = downloadUrl;
        }
        // Add gender to profile data
        if (_selectedGender != null) {
          _profile['gender'] = _selectedGender.toString().split('.').last;
        }
        await _firestore.collection('users').doc(_user!.uid).set(_profile);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile saved')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('User Profile',style: TextStyle(color:Colors.white),),
              backgroundColor: Colors.black38,
    iconTheme: IconThemeData(color: Colors.white)
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: <Widget>[
            SizedBox(height: 20),
            _buildCircularAvatar(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _pickImageFromGallery,
                  child: Text('Upload Image'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _takePhoto,
                  child: Text('Take Photo'),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildFirstNameField(),
            SizedBox(height: 20),
            _buildLastNameField(),
            SizedBox(height: 20),
            TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              initialValue: _profile['email'] ?? '',
              onSaved: (value) => _profile['email'] = value,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your email';
                } else if (!RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
            SizedBox(height: 25),
            TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              initialValue: _profile['phoneNumber'] ?? '',
              onSaved: (value) => _profile['phoneNumber'] = value,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter your phone number';
                } else if (value.length != 10) {
                  return 'Phone number must be 10 digits';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Age',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.number,
              initialValue: _profile['age'] ?? '',
              onSaved: (value) => _profile['age'] = value,
              validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
            ),
            SizedBox(height: 20),
            TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Weight',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.number,
              initialValue: _profile['weight'] ?? '',
              onSaved: (value) => _profile['weight'] = value,
              validator: (value) => value!.isEmpty ? 'Please enter your weight' : null,
            ),
            SizedBox(height: 20),
            _buildGenderSelection(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveUserProfile,
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularAvatar() {
    String? initials;

    // Check if first name and last name are available
    if (_profile.containsKey('firstName') && _profile.containsKey('lastName')) {
      String firstName = _profile['firstName'] as String;
      String lastName = _profile['lastName'] as String;

      // Extract initials from first name and last name
      if (firstName.isNotEmpty && lastName.isNotEmpty) {
        initials = '${firstName[0]}${lastName[0]}';
      } else if (firstName.isNotEmpty) {
        initials = firstName[0];
      } else if (lastName.isNotEmpty) {
        initials = lastName[0];
      }
    }

    return Center(
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
        backgroundImage: _imageFile != null
            ? FileImage(_imageFile!)
            : (_profile.containsKey('photoUrl') && _profile['photoUrl'] is String)
            ? NetworkImage(_profile['photoUrl'] as String)
            : AssetImage('assets/default_avatar.png') as ImageProvider, // Provide path to your default avatar image
        child: _imageFile == null &&
            (_profile.containsKey('firstName') &&
                _profile['firstName'] is String &&
                _profile.containsKey('lastName') &&
                _profile['lastName'] is String &&
                (_profile['firstName'] as String).isNotEmpty &&
                (_profile['lastName'] as String).isNotEmpty)
            ? Text(
          '${_profile['firstName'][0]}${_profile['lastName'][0]}',
          style: TextStyle(color: Colors.white),
        )
            : null,
      ),
    );
  }

  Widget _buildFirstNameField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'First Name',
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      initialValue: _profile['firstName'] ?? '',
      onSaved: (value) => _profile['firstName'] = value,
      validator: (value) => value!.isEmpty ? 'Please enter your first name' : null,
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Last Name',
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      initialValue: _profile['lastName'] ?? '',
      onSaved: (value) => _profile['lastName'] = value,
      validator: (value) => value!.isEmpty ? 'Please enter your last name' : null,
    );
  }

  Widget _buildGenderSelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          'Gender',
          style: TextStyle(color: Colors.white),
        ),
        Row(
          children: [
            Radio<Gender>(
              value: Gender.Male,
              groupValue: _selectedGender,
              onChanged: (Gender? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              activeColor: _selectedGender == Gender.Male ? Colors.lightGreen : null,
            ),
            Text('Male', style: TextStyle(color: Colors.white)),
          ],
        ),
        Row(
          children: [
            Radio<Gender>(
              value: Gender.Female,
              groupValue: _selectedGender,
              onChanged: (Gender? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              activeColor: _selectedGender == Gender.Female ? Colors.lightGreen : null,
            ),
            Text('Female', style: TextStyle(color: Colors.white)),
          ],
        ),
        Row(
          children: [
            Radio<Gender>(
              value: Gender.Other,
              groupValue: _selectedGender,
              onChanged: (Gender? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              activeColor: _selectedGender == Gender.Other ? Colors.lightGreen : null,
            ),
            Text('Other', style: TextStyle(color: Colors.white)),
          ],
        ),
      ],
    );
  }
}
