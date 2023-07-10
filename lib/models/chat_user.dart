class ChatUser {
  ChatUser({
    required this.image,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.id,
    required this.isOnline,
    required this.lastActive,
    required this.email,
    required this.pushToken,
  });
  late  String image;
  late  String name;
  late  String about;
  late  String createdAt;
  late  String id;
  late  bool isOnline;
  late  String lastActive;
  late  String email;
  late  String pushToken;

  ChatUser.fromJson(Map<dynamic, dynamic> json){
    image = json['image']??'';
    name = json['name']??'';
    about = json['about']??'';
    createdAt = json['created_at'??''];
    id = json['id']??'';
    isOnline = json['is_online']??'';
    lastActive = json['last_active']??'';
    email = json['email']??'';
    pushToken = json['push_token']??'';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['about'] = about;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['is_online'] = isOnline;
    data['last_active'] = lastActive;
    data['email'] = email;
    data['push_token'] = pushToken;
    return data;
  }
}