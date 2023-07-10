import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_chatapp/api/apis.dart';
import 'package:demo_chatapp/helper/dialogs.dart';
import 'package:demo_chatapp/helper/my_date_util.dart';
import 'package:demo_chatapp/models/chat_user.dart';
import 'package:demo_chatapp/screens/auth/login_screen.dart';
import 'package:demo_chatapp/widgets/chat_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ViewProfileScreenState createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // appbar
          appBar: AppBar(
            title: Text(widget.user.name),
          ),

          floatingActionButton:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Joined On: ',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),),
              Text(myDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt,showYear: true),
                  style: const TextStyle(
                      color: Colors.black54, fontSize: 16)),
            ],
          ),

          body:
          Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(width: mq.width, height: mq.height * 0.03),

                  ClipRRect(
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
                  SizedBox(height: mq.height * 0.03),
                  Text(widget.user.email,
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 16)),
                  SizedBox(height: mq.height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('About: ',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),),
                      Text(widget.user.about,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          )
      ),

    );
  }
}

