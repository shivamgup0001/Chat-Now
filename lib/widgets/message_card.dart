import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo_chatapp/api/apis.dart';
import 'package:demo_chatapp/helper/my_date_util.dart';
import 'package:flutter/material.dart';

import '../models/message.dart';
import '../screens/auth/login_screen.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  const MessageCard({Key? key, required this.message}) : super(key: key);

  @override
  _MessageCardState createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid==widget.message.fromId?
    _greenMessage()
    :_blueMessage();
  }

  // sender or another user message
  Widget _blueMessage(){

    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width*0.04),
            margin : EdgeInsets.symmetric(
              horizontal: mq.width *0.04, vertical: mq.height * 0.01
            ),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255,221,245,255),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              )
            ),
            child:
            widget.message.type ==Type.text?
            Text(widget.message.msg,
            style: const TextStyle(fontSize:15, color: Colors.black87))
                :
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context,url)=>
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2,),
                    ),
                errorWidget: (context, url, error) => const Icon(Icons.image,size:70),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width*.04),
          child: Text(myDateUtil.getFormattedTime(context: context, time: widget.message.sent),
          style: const TextStyle(fontSize: 13, color: Colors.black54)),
        )
      ],
    );
  }

  // our or user message
  Widget _greenMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        Row(
          children: [

             SizedBox(width: mq.width*.04),

            if (widget.message.read.isNotEmpty)
            const Icon(Icons.done_all_rounded, color: Colors.blue,size:20),

            const SizedBox(width : 2),

            Text(
    myDateUtil.getFormattedTime(context: context, time: widget.message.sent),
                style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(mq.width*0.04),
            margin : EdgeInsets.symmetric(
                horizontal: mq.width *0.04, vertical: mq.height * 0.01
            ),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255,218,255,176),
                border: Border.all(color: Colors.lightGreen),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                )
            ),
            child: widget.message.type ==Type.text?
            Text(widget.message.msg,
                style: const TextStyle(fontSize:15, color: Colors.black87))
                :
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context,url) =>
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2,),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.image,size:70),
              ),
            ),
          ),
        ),
      ],
    );
  }
  }