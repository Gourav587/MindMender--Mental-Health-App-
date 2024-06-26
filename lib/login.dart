import 'package:myproject/forgot_password.dart';
import 'package:myproject/home.dart';
import 'package:myproject/service/auth.dart';
import 'package:myproject/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myproject/squaretile.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key}); // Fixed the key syntax

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  String email = "", password = "";

  TextEditingController mailcontroller = TextEditingController(); // Removed 'new' keyword
  TextEditingController passwordcontroller = TextEditingController(); // Removed 'new' keyword

  final _formkey = GlobalKey<FormState>();

  Future<void> userLogin() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      // Navigate to home page if login is successful
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // Show snackbar message if user is not registered
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "User is not registered",
            style: TextStyle(fontSize: 18.0,color: Colors.red),
          ),
        ));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text(
            "Wrong Password Provided by User",
            style: TextStyle(fontSize: 18.0,color: Colors.red),
          ),
        ));
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6AB88),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  "assets/images/pic.png",
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Home()),
                  );
                },


                child: const Text(
                  'Skip this',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Form(
                  key: _formkey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                          decoration: BoxDecoration(
                              color: const Color(0xFFedf0f8),
                              borderRadius: BorderRadius.circular(30)),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter E-mail';
                              }
                              return null;
                            },
                            controller: mailcontroller,
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Email",
                                hintStyle: TextStyle(
                                    color: Color(0xFFb2b7bf), fontSize: 18.0)),
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 30.0),
                          decoration: BoxDecoration(
                              color: const Color(0xFFedf0f8),
                              borderRadius: BorderRadius.circular(30)),
                          child: TextFormField(
                            controller: passwordcontroller,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Password';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Password",
                                hintStyle: TextStyle(
                                    color: Color(0xFFb2b7bf), fontSize: 18.0)),
                            obscureText: true,
                          ),
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                email = mailcontroller.text;
                                password = passwordcontroller.text;
                              });
                              await userLogin(); // Await userLogin directly
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 30.0),
                            decoration: BoxDecoration(
                                color: const Color(0xFFEC5B17),
                                borderRadius: BorderRadius.circular(30)),
                            child: const Center(
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPassword()));
                },
                child: const Text("Forgot Password?",
                    style: TextStyle(
                        color: Color(0xff111111),
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Text(
                "or LogIn with",
                style: TextStyle(
                    color: Color(0xff111111),
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      AuthMethods().signInWithGoogle(context);
                    },
                    child: const SquareTile(imagePath: "assets/images/google .png"),
                  ),
                  const SizedBox(width: 25),
                  GestureDetector(
                    onTap: () {
                      AuthMethods().signInWithApple();
                    },
                    child: const SquareTile(imagePath: "assets/images/apple1.png"), // Use SquareTile here
                  ),
                ],
              ),
              const SizedBox(
                height: 40.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?",
                      style: TextStyle(
                          color: Color(0xff111111),
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(
                    width: 5.0,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => const SignUp()));
                    },
                    child: const Text(
                      "SignUp",
                      style: TextStyle(
                          color: Color(0xff111111),
                          fontSize: 20.0,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
