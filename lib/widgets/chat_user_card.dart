import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_chatapp/helper/my_date_util.dart';
import 'package:demo_chatapp/models/chat_user.dart';
import 'package:demo_chatapp/models/message.dart';
import 'package:demo_chatapp/screens/auth/login_screen.dart';
import 'package:demo_chatapp/widgets/dialogs/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({Key? key, required this.user}) : super(key: key);

  @override
  _ChatUserCardState createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {

  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (_)=> ChatScreen(user : widget.user)));
        },
        child: StreamBuilder<QuerySnapshot<Map>>(
          stream: APIs.getLastMessage(widget.user),
          builder: (context,snapshot){

            final data=snapshot.data?.docs;
            //print('${jsonEncode(data![0].data())}');

            final list=data?.map((e) => Message.fromJson(e.data())).toList()??[];

            if(list.isNotEmpty)
              {
                _message=list[0];
              }


            return ListTile(
              // leading: const CircleAvatar(child: Icon(CupertinoIcons.person),),
              leading: InkWell(
                onTap: (){
                  showDialog(context: context, builder: (_)=>ProfileDialog(user: widget.user,));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .3),
                  child: CachedNetworkImage(
                    width: mq.height*.055,
                    height: mq.height*.055,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(child: Icon(CupertinoIcons.person),),
                  ),
                ),
              ),
              title: Text(widget.user.name),
              subtitle: Text(_message!=null?
              _message!.type==Type.image
              ?'Image'
              :_message!.msg:widget.user.about,maxLines: 1),
              trailing:_message==null?null:
              _message!.read.isEmpty&&_message!.fromId!=APIs.user.uid?
              Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(color: Colors.greenAccent.shade400, borderRadius: BorderRadius.circular(10))
              ):
              Text(myDateUtil.getLastMessageTime(context: context, time: _message!.sent),
              style: TextStyle(color: Colors.black54),),
            );
          },
        )
        ),
      );
  }
}
