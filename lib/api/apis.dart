import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_chatapp/models/chat_user.dart';
import 'package:demo_chatapp/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';

class APIs{
  // for authentication
  static FirebaseAuth auth= FirebaseAuth.instance;

  //for accessing cloud firestore database
  static FirebaseFirestore firestore= FirebaseFirestore.instance;

  static FirebaseStorage storage= FirebaseStorage.instance;

  static FirebaseMessaging fMessaging=FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((value){
      if(value!=null)
        {
          me.pushToken=value;
          print('PushToken : $value');
        }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static Future<void> sendPushNotification(ChatUser chatUser, String msg) async{
    try{
      final body={
        "to" : chatUser.pushToken,
        "notification" :{
          "title" : chatUser.name,
          "android_channel_id": "chats",
          "body" : msg
        },
        "data": {
          "some_data" : "User ID : ${me.id}",
        },
      };
      var response = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader : 'application/json',
            HttpHeaders.authorizationHeader : 'key=AAAAq1sj7kg:APA91bHgwczwc01-YQADtMXmy42_FCm97HppdQ8r7Rg91X5fHU89f_hYkZjfrX17ZX9fXaj0Zkc1XuaCtpiajsGMgBMZFRJmESMpkjgA_T6AhW__e27WqP-7Rn0g_AyXu2yce06zlzTb'
          },
          body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }catch(e){
      print('\n error notification : $e');
    }
  }

  static late ChatUser me;

  //to return current user
static User get user=> auth.currentUser!;

  //for checking if user exists or not
static Future<bool> userExists() async{
  return (await firestore
  .collection('users')
  .doc(user.uid)
  .get())
  .exists;
}

  static Future<bool> addChatUser(String email) async{
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo : email)
        .get();

    if(data.docs.isNotEmpty && data.docs.first.id!=user.uid)
      {
        firestore.collection('users').doc(user.uid)
        .collection('my_users').doc(data.docs.first.id)
        .set({});
        return true;
      }
    else
      {
        return false;
      }
  }

  static Future<void> getSelfInfo() async{
    await firestore
        .collection('users')
        .doc(user.uid)
        .get().then((user) async{
          if (user.exists){
            me=ChatUser.fromJson(user.data()!);
            await getFirebaseMessagingToken();

            updateActiveStatus(true);
          }else{
            await createUser().then((value) => getSelfInfo());
          }
    });
  }

  // for creating a new user
  static Future<void> createUser() async{

  final time= DateTime.now().millisecondsSinceEpoch.toString();

  final chatUser=ChatUser(image: user.photoURL.toString(), name: user.displayName.toString(), about: "Hey, I'm using Chat Now !", createdAt: time, id: user.uid, isOnline: false, lastActive: time, email: user.email.toString(), pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId(){
    return firestore.collection('users').doc(user.uid).collection('my_users').snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(List<String> userIds){
  return firestore.collection('users').where('id',whereIn: userIds.isEmpty?['']:userIds).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUser chatUser){
    return firestore.collection('users').where('id',isEqualTo: chatUser.id).snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async{
    firestore.collection('users').doc(user.uid)
    .update({'is_online': isOnline,
    'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  static Future<void> sendFirstMessage(ChatUser chatUser,String msg, Type type) async{
    await firestore
        .collection('users')
        .doc(chatUser.id)
    .collection('my_users')
    .doc(user.uid)
    .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  static Future<void> updateUserInfo() async{
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'name':me.name,
      'about':me.about,
    });
  }

  static Future<void> updateProfilePicture(File file) async{
  final ext = file.path.split('.').last;
  final ref = storage.ref().child('profile_pictures/${user.uid}/$ext');

  await ref.
    putFile(file,SettableMetadata(contentType: 'image/$ext'));

  me.image=await ref.getDownloadURL();
  await firestore
      .collection('users')
      .doc(user.uid)
      .update({'image':me.image});
  }

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_${id}'
  :'${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(ChatUser user){
    return firestore.collection('chats/${getConversationID(user.id)}/messages').
    orderBy('sent',descending: true).snapshots();
  }

  static Future<void> sendMessage(ChatUser chatUser,String msg,Type type) async{

    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final Message message=Message(toId: chatUser.id, msg: msg, read: '', type: type, sent: time, fromId: user.uid);

    final ref= firestore.collection('chats/${getConversationID(chatUser.id)}/messages');

    await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUser,type==Type.text? msg:'image'));

  }

  static Future<void> updateMessageReadStatus(Message message) async{
    firestore.collection('chats/${getConversationID(message.fromId)}/messages')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUser user){
    return firestore.collection('chats/${getConversationID(user.id)}/messages').
    orderBy('sent',descending: true).limit(1).snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async{
    final ext = file.path.split('.').last;
    final ref = storage.ref().child('images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}/$ext');

    await ref.
    putFile(file,SettableMetadata(contentType: 'image/$ext'));

    final imageUrl=await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

}