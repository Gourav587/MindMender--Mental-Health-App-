import 'dart:ffi';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class VideoCall extends StatelessWidget {
  VideoCall({Key? key}) : super(key: key);

  final TextEditingController conferenceIdController = TextEditingController();
  final String userId = (Random().nextInt(900000) + 100000).toString();
  final String RandomConferenceId = (Random().nextInt(10000000)*10+Random().nextInt(10)).toString().padLeft(10,'0');

  @override
  Widget build(BuildContext context) {
    var buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.brown,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF251404),
              Color(0xFF261505),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Text('MindMender TherapyConnect',style: TextStyle(color:Colors.white, fontSize: 40,fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,),
              SizedBox(height: 50,),
              Text('Your UserId: $userId', style: TextStyle(color: Colors.white)),
              const Text('Please test', style: TextStyle(color: Colors.white)),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                maxLength: 10,
                keyboardType: TextInputType.number,
                controller: conferenceIdController,
                decoration: InputDecoration(
                  labelText: 'Join a Meeting by Input an ID',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              ElevatedButton(
                style: buttonStyle,
                onPressed: () => jumpToMeetingPage(
                  context,
                  conferenceId: conferenceIdController.text,
                ),
                child: const Text('Join a Meeting',style: TextStyle(color: Colors.white),),
              ),
              const SizedBox(
                height: 16,
              ),
              ElevatedButton(
                style: buttonStyle,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Meeting ID'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: [
                              Text('New Meeting ID: $RandomConferenceId'),
                              Text('Use this ID to start a new meeting.'),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('New Meeting',style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void jumpToMeetingPage(BuildContext context, {required String conferenceId}) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoConferencePage(
            conferenceID: conferenceId,
          ),
        ),
      );
    } catch (e) {
      print('Failed to navigate: $e');
    }
  }
}

class VideoConferencePage extends StatelessWidget {
  final String conferenceID;

  VideoConferencePage({required this.conferenceID, Key? key}) : super(key: key);

  final int appID = int.parse(dotenv.get('ZEGO_APP_ID')!);
  final String appSign = dotenv.get('ZEGO_APP_SIGN')!;
  final String userID = Random().nextInt(900000).toString();
  final String userName = "user_name"; // Change as needed

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF251404),
                Color(0xFF261505),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ZegoUIKitPrebuiltVideoConference(
            appID: appID,
            appSign: appSign,
            conferenceID: conferenceID,
            userID: userID,
            userName: userName,
            config: ZegoUIKitPrebuiltVideoConferenceConfig(),
          ),
        ),
      );
    } catch (e) {
      print('Failed to build video conference page: $e');
      return Scaffold(
        body: Center(
          child: Text('Failed to load video conference. Please try again.'),
        ),
      );
    }
  }
}
