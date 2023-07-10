import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo_chatapp/models/chat_user.dart';
import 'package:demo_chatapp/screens/auth/view_profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../screens/auth/login_screen.dart';

class ProfileDialog extends StatelessWidget{
  const ProfileDialog({super.key, required this.user});
  final ChatUser user;
  @override
  Widget build(BuildContext context){
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width *.6,
        height: mq.height*.35,
        child: Stack(
          children: [

            Positioned(
              top: mq.height*.075,
              left: mq.width*.1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .25),
                child: CachedNetworkImage(
                  width: mq.width * .5,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) =>
                  const CircleAvatar(
                    child: Icon(CupertinoIcons.person),),
                ),
              ),
            ),

            Positioned(
              left: mq.width * 0.04,
              top: mq.height*.02,
              width: mq.width*.55,
              child: Text(user.name,
              style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w500),),
            ),

            Positioned(
              right: 8,
              top: 6,
              child: MaterialButton(
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_)=> ViewProfileScreen(user: user))
                  );
                },
                minWidth: 0,
                padding: EdgeInsets.all(0),
                shape: CircleBorder(),
                child:
                Icon(Icons.info_outline, color: Colors.blue,size:30),
              ),
            )
          ],
        ),
      ),
    );
  }
}