import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/message.dart';
import '../models/user_model.dart';
import 'package:http/http.dart' as http;

class Apis {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;

  static late ChatUser me;

  static User get user => auth.currentUser!;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> getMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log("PushToken = $t");
      }
    });
    FirebaseMessaging.onMessage.listen((message) {
      log("Notification${message.data}");
      if (message.notification != null) {
        log("${message.notification}");
      }
    });
  }

  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  static Future<bool> addUser(String email) async {
    final data = await firestore
        .collection('users')
        .where("email", isEqualTo: email)
        .get();
    log("user email ${data.docs}");
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      firestore
          .collection("users")
          .doc(user.uid)
          .collection("my_users")
          .doc(data.docs.first.id)
          .set({});
      log("user ${data.docs.first.data()}");
      return true;
    } else {
      return false;
    }
  }

  static Future<void> deleteUser(String email) async {
    final data = await firestore
        .collection('users')
        .where("email", isEqualTo: email)
        .get();
     await  firestore
          .collection("users")
          .doc(user.uid)
          .collection("my_users")
          .doc(data.docs.first.id)
          .delete();
  }


  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": chatUser.name,
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "click_action": "UserId : ${me.id}",
        },
      };
      var res =
          await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
              headers: {
                HttpHeaders.contentTypeHeader: "application/json",
                HttpHeaders.authorizationHeader:
                    "key = AAAAw_kzMls:APA91bFH6qI4sgwQfMzCGKn9YS1MhND_vy96lY50ZQiw8WXAaC3O7r8NFT7SWHcat4mY4bsLNz9SdU53GCXuO-EAc4bDA3IWJxf9BJRCmo4lSCnAhjYK3-KQcGj6AS-J3klhvpMwfolR"
              },
              body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log("Notification Error $e");
    }
  }

  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using We Chat! ",
      image: user.photoURL.toString(),
      createAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(List<String> userIds) {
    if(userIds.isEmpty){
      return const Stream.empty();
    }else {
      return firestore
          .collection('users')
          .where('id', whereIn: userIds)
          .snapshots();
    }
  }

  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getMessagingToken();
        Apis.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log('Extension : $ext');
    final ref = storage.ref().child('profile_picture/ ${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred :${p0.bytesTransferred / 1000} kb');
    });
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  // **************Apis*********************
  static getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // Chat user msg
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: "",
        type: type,
        fromId: user.uid,
        sent: time);
    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : "image"));
  }

  static Future<void> getMessageReadTime(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({"read": DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    final ext = file.path.split('.').last;

    final ref = storage.ref().child(
        'images/ ${getConversationID(chatUser.id)}/${DateTime.now().microsecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred :${p0.bytesTransferred / 1000} kb');
    });
    final imageUrl = await ref.getDownloadURL();
    await Apis.sendMessage(chatUser, imageUrl, Type.image);
  }

  static Future<void> deleteMessages(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  static Future<void> updateMessages(Message message, String updateMsg) async {
    firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({"msg": updateMsg});
  }
}
