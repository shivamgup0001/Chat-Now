import 'dart:developer';
import 'dart:io';

import 'package:demo_chatapp/api/apis.dart';
import 'package:demo_chatapp/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../helper/dialogs.dart';

late Size mq;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

_handleGoogleButtonClick(BuildContext context){
  _signInWithGoogle(context).then((user) async{
    if(user!=null) {
      log('\nUser : ${user.user}');
      if((await APIs.userExists())){
        Navigator.pushReplacement(
            context,MaterialPageRoute(builder: (_)=>const HomeScreen()));
      }else{
        await APIs.createUser().then((value){
          Navigator.pushReplacement(
              context,MaterialPageRoute(builder: (_)=>const HomeScreen()));
        });
      }

    }
  });
}

Future<UserCredential?> _signInWithGoogle(BuildContext context) async {
  try{
    await InternetAddress.lookup('google.com');
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await APIs.auth.signInWithCredential(credential);
  } catch(e){
    log('\n signInWithGoogle: $e');
    Dialogs.showSnackbar(context,'Something wrong with Internet');
    return null;
  }
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    mq= MediaQuery.of(context).size;
    return Scaffold(
      // appbar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to Chat Now'),
      ),
      body: Stack(children: [
        Positioned(
          top: mq.height*.15,
            width: mq.width*.50,
            left: mq.width*.25,
            child: Image.asset('images/message.png')),
        Positioned(
            bottom: mq.height*.15,
            width: mq.width*.9,
            left: mq.width*.05,
            height: mq.height*.07,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreenAccent.shade400,
                shape: const StadiumBorder(),
                elevation: 1),
                onPressed: (){
                  _handleGoogleButtonClick(context);
                },
                icon: Image.asset('images/google.png',height: mq.height*0.06),
                label: Text('Signin with Google')))
      ]),
    );
  }
}
