import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_chatapp/helper/my_date_util.dart';
import 'package:demo_chatapp/screens/auth/view_profile_screen.dart';
import 'package:demo_chatapp/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import 'auth/login_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list=[];

  final _textController = TextEditingController();

  bool _showEmoji = false,_isUploading=false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=> FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if(_showEmoji){
              setState(() {
                _showEmoji=!_showEmoji;
              });
              return Future.value(false);
            }else{
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),

            backgroundColor: const Color.fromARGB(255,234,248,255),

            body : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map>>(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context,snapshot) {

                      switch(snapshot.connectionState){
                      //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                         return const SizedBox();

                      // if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data=snapshot.data?.docs;
                          //print('${jsonEncode(data![0].data())}');
                           _list=data?.map((e) => Message.fromJson(e.data())).toList()??[];

                      //final _list=['hi','hello'];

                          if(_list.isNotEmpty){
                            return ListView.builder(
                              reverse: true,
                                itemCount:_list.length,
                                padding: EdgeInsets.only(top: mq.height*0.01),
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(message: _list[index],);
                                });
                          }else{
                            return Center(child: const Text('Say Hii!👋',style: TextStyle(fontSize: 20),));
                          }

                      }
                    },
                  ),
                ),

                if(_isUploading)
                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(strokeWidth: 2,),
                  ),
                ),


                _chatInput(),
if(_showEmoji)
      SizedBox(
          height: mq.height* .35,
          child: EmojiPicker(
          textEditingController: _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
          config: Config(
            bgColor: const Color.fromARGB(255,234,248,255),
          columns: 7,
          emojiSizeMax: 32 * (Platform.isIOS? 1.30 : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
          ),
          ),
      )

                ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _appBar(){
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder<QuerySnapshot<Map>>(
        stream: APIs.getUserInfo(widget.user),builder: (context,snapshot){

        final data=snapshot.data?.docs;
        //print('${jsonEncode(data![0].data())}');

        final list=data?.map((e) => ChatUser.fromJson(e.data())).toList()??[];

        return Row(
          children: [
            IconButton(onPressed: ()=> Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.black54)),

            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .03),
              child: CachedNetworkImage(
                width: mq.height*.05,
                height: mq.height*.05,
                imageUrl: list.isNotEmpty? list[0].image:widget.user.image,
                errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person),),
              ),
            ),

            const SizedBox(width : 10),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(list.isNotEmpty?list[0].name : widget.user.name,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500
                    )),

                const SizedBox(height: 2,),

                Text(list.isNotEmpty?
                list[0].isOnline
                    ?'Online'
                :myDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                    :myDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),

              ],
            )

          ],
        );
      })
    );
  }

  Widget _chatInput(){
    return
      Padding(
        padding: EdgeInsets.symmetric(vertical: mq.height*0.01,horizontal: mq.width*.025),
        child: Row(
          children: [
          Expanded(
            child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Row(children: [
              IconButton(onPressed: (){
                setState(() {
                  FocusScope.of(context).unfocus();
                  _showEmoji=!_showEmoji;
                });
              },
                  icon: const Icon(Icons.emoji_emotions, color: Colors.blueAccent,size:25)),

              Expanded(child: TextField(
                keyboardType: TextInputType.multiline,
                controller: _textController,
                maxLines: null,
                onTap: (){
                  if(_showEmoji)
                    setState(() {
                      _showEmoji=!_showEmoji;
                    });
                },
                decoration: const InputDecoration(hintText: 'Type Something...',
                    hintStyle: TextStyle(color: Colors.blueAccent),
                border: InputBorder.none),
              )),

              IconButton(onPressed: ()async {
                final picker = ImagePicker();
                final List<XFile> xfilePick = await picker.pickMultiImage(imageQuality : 80);

                for(var i in xfilePick) {
                  setState(() {
                    _isUploading=true;
                  });
                  await APIs.sendChatImage(widget.user, File(i!.path));
                  setState(() {
                    _isUploading=false;
                  });
                }
              },
                  icon: const Icon(Icons.image, color: Colors.blueAccent,size:26)),

              IconButton(onPressed: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(source: ImageSource.camera,imageQuality : 80);
                XFile? xfilePick = pickedFile;

                setState(() {
                  _isUploading=true;
                });
                APIs.sendChatImage(widget.user,File(xfilePick!.path));
                setState(() {
                  _isUploading=false;
                });
              },
                  icon: const Icon(Icons.camera_alt_rounded, color: Colors.blueAccent,size:26)),

              SizedBox(width: mq.width *.02,),
            ],
            ),
    ),
          ),

            MaterialButton(onPressed: (){
              if(_textController.text.isNotEmpty){
                if(_list.isEmpty){
                  APIs.sendFirstMessage(widget.user, _textController.text, Type.text);
                }else
                APIs.sendMessage(widget.user, _textController.text,Type.text);
                _textController.text='';
              }
            },
              minWidth: 0,
              padding: const EdgeInsets.only(top:10,bottom: 10,left:10,right:5),
            shape: const CircleBorder(),
            color: Colors.green,
            child: const Icon(Icons.send, color: Colors.white,size:28),)
        ]
        ),
      );
  }
}