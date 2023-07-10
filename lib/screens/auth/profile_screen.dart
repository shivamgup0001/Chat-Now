import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_chatapp/api/apis.dart';
import 'package:demo_chatapp/helper/dialogs.dart';
import 'package:demo_chatapp/models/chat_user.dart';
import 'package:demo_chatapp/screens/auth/login_screen.dart';
import 'package:demo_chatapp/widgets/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final _formkey = GlobalKey<FormState>();
  File? galleryFile;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // appbar
          appBar: AppBar(
            title: const Text('Profile Screen'),
          ),

          // floating access button to add new users
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.redAccent,
              onPressed: () async {
                Dialogs.showProgressBar(context);

                await APIs.updateActiveStatus(false);

                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    APIs.auth=FirebaseAuth.instance;
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => LoginScreen()));
                  });
                });
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),

          body:
          Form(
            key: _formkey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(width: mq.width, height: mq.height * 0.03),

                    Stack(
                      children: [
                        galleryFile!=null?
                        ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .1),
                          child: Image.file(
                            galleryFile!,
                            width: mq.height * .2,
                            height: mq.height * .2,
                            fit: BoxFit.cover,
                          ),
                        )
                            :ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .1),
                          child: CachedNetworkImage(
                            width: mq.height * .2,
                            height: mq.height * .2,
                            fit: BoxFit.fill,
                            imageUrl: widget.user.image,
                            errorWidget: (context, url, error) =>
                            const CircleAvatar(
                              child: Icon(CupertinoIcons.person),),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              _showBottomSheet();
                            },
                            shape: const CircleBorder(),
                            color: Colors.white,
                            child: const Icon(Icons.edit, color: Colors.blue,),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: mq.height * 0.03),
                    Text(widget.user.email,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 16)),
                    SizedBox(height: mq.height * 0.05),
                    TextFormField(
                        initialValue: widget.user.name,
                        onSaved: (val) => APIs.me.name = val ?? '',
                        validator: (val) =>
                        val != null && val.isNotEmpty
                            ? null
                            : 'Required Field',
                        decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.person, color: Colors.blue,),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)
                            ),
                            hintText: 'eg. Happy Singh',
                            label: const Text('Name'))
                    ),
                    SizedBox(height: mq.height * .02,),
                    TextFormField(
                        initialValue: widget.user.about,
                        onSaved: (val) => APIs.me.about = val ?? '',
                        validator: (val) =>
                        val != null && val.isNotEmpty
                            ? null
                            : 'Required Field',
                        decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.info_outline, color: Colors.blue,),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)
                            ),
                            hintText: 'eg. Feeling Happy',
                            label: const Text('About'))
                    ),

                    SizedBox(height: mq.height * .05,),

                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            minimumSize: Size(mq.width * .5, mq.height * .06)
                        ), onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        _formkey.currentState!.save();
                        APIs.updateUserInfo().then((value) =>
                        (
                            Dialogs.showSnackbar(
                                context, 'Profile Updated Successfully')
                        ));
                      }
                    },
                        icon: const Icon(Icons.edit, size: 28,),
                        label: const Text(
                          'UPDATE', style: TextStyle(fontSize: 16),)
                    )
                  ],
                ),
              ),
            ),
          )
      ),

    );
  }
  Future getImage(
      ImageSource img,
      ) async {
    final pickedFile = await picker.pickImage(source: img,imageQuality : 80);
    XFile? xfilePick = pickedFile;
    setState(
          () {
        if (xfilePick != null) {
          galleryFile = File(pickedFile!.path);
        } else {
          ScaffoldMessenger.of(context).showSnackBar( // is this context <<<
              const SnackBar(content: Text('Nothing is selected')));
        }
      },
    );
    APIs.updateProfilePicture(galleryFile!);
  }

    void _showBottomSheet(){
      showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20))),
          builder: (_){
            return ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: mq.height*.03,bottom: mq.height*0.05),
              children: [
                const Text('Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                SizedBox(height:mq.height*0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize : Size(mq.width* .3,mq.height * .15),
                      ), onPressed: () {
                      getImage(ImageSource.gallery);
                      Navigator.of(context).pop();
                    }, child: Image.asset('images/add_image.png'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        fixedSize : Size(mq.width* .3,mq.height * .15),
                      ), onPressed: () {
                      getImage(ImageSource.camera);
                      Navigator.of(context).pop();
                    }, child: Image.asset('images/camera.png'),
                    )
                  ]
                )
              ],
            );
          });
    }
  }

