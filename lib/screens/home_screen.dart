import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_chatapp/api/apis.dart';
import 'package:demo_chatapp/models/chat_user.dart';
import 'package:demo_chatapp/screens/auth/login_screen.dart';
import 'package:demo_chatapp/screens/auth/profile_screen.dart';
import 'package:demo_chatapp/widgets/chat_user_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../helper/dialogs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<ChatUser> list=[];
  final List<ChatUser> _searchlist=[];

  bool _isSearching =false;

  @override
  void initState() {

    super.initState();
    APIs.getSelfInfo();

    //APIs.updateActiveStatus(true);

    SystemChannels.lifecycle.setMessageHandler((message) {

      if(APIs.auth.currentUser!=null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(
            true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(
            false);
        }
      }
        return Future.value(message);
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if(_isSearching){
            setState(() {
              _isSearching=!_isSearching;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          // appbar
          appBar: AppBar(
            title: _isSearching
                ?TextField(
              decoration: const InputDecoration(border: InputBorder.none,hintText: 'Name, Email, ...'),
              autofocus: true,
              style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
              onChanged: (val){
                _searchlist.clear();

                for(var i in list){
                  if(i.name.toLowerCase().contains(val.toLowerCase())||
                  i.email.toLowerCase().contains(val.toLowerCase())){
                    _searchlist.add(i);
                  }
                  setState(() {
                    _searchlist;
                  });
                }
              },
            )
                :const Text('Chat Now'),
            leading: const Icon(CupertinoIcons.home),
            actions: [
              // search-user button
              IconButton(onPressed: (){
                setState(() {
                  _isSearching=!_isSearching;
                });
              }, icon: Icon(_isSearching
                  ? CupertinoIcons.clear_circled_solid
              :Icons.search)),
              // more-features button
              IconButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(user: APIs.me)));
              }, icon: const Icon(Icons.more_vert))
            ],
          ),

          // floating access button to add new users
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom:10),
            child: FloatingActionButton(
              onPressed: (){
                _addChatUserDialog();
              },child: const Icon(Icons.add_comment_rounded),
            ),
          ),

          body: StreamBuilder<QuerySnapshot<Map>>(
            stream: APIs.getMyUsersId(),
            builder: (context,snapshot){

              switch(snapshot.connectionState) {
              //if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  //return const Center(child: CircularProgressIndicator());

              // if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder<QuerySnapshot<Map>>(
                      stream: APIs.getAllUsers(
                          snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                      builder: (context, snapshot) {
                        final data = snapshot.data?.docs;
                        list = data?.map((e) => ChatUser.fromJson(e.data()))
                            .toList() ?? [];

                        if (list.isNotEmpty) {
                          return ListView.builder(
                              itemCount: _isSearching
                                  ? _searchlist.length
                                  : list.length,
                              padding: EdgeInsets.only(top: mq.height * 0.01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return ChatUserCard(user:
                                _isSearching
                                    ? _searchlist[index]
                                    : list[index],);
                                // return Text('Name: ${list[index]}');
                              });
                        } else {
                          return const Center(child: Text(
                            'No connections found!',
                            style: TextStyle(fontSize: 20),));
                        }
                      }
                  );
              }
          }, ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';
    showDialog(context: context, builder: (_) =>AlertDialog(
      contentPadding: const EdgeInsets.only(
        left : 24,right : 24 ,top : 20 , bottom  : 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),

      title: const Row(
        children: [
          Icon(
          Icons.person_add,
            color: Colors.blue,
            size:28,
          ),
          Text(' Add User')
        ],
      ),

      content: TextFormField(
        maxLines: null,
        onChanged: (value) => email =value,
        decoration: InputDecoration(
          hintText: 'Email Id',
          prefixIcon: const Icon(Icons.email,color: Colors.blue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15)
          )
        ),

      ),

      actions: [
        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },
      child :  const Text(
      'Cancel',
      style: TextStyle(color: Colors.blue,fontSize: 16),)),

        MaterialButton(onPressed: () async {
          Navigator.pop(context);
          if(email.isNotEmpty) {
            await APIs.addChatUser(email).then((value) {
              if(!value){
                Dialogs.showSnackbar(
                  context, 'User does not exist'
                );
              }
            });
          }
        },
            child :  const Text(
              'Add',
              style: TextStyle(color: Colors.blue,fontSize: 16),))
      ],
    ));
  }
}
