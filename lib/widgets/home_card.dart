import 'package:flutter/material.dart';
import 'package:wechat/helper/apis.dart';
import 'package:wechat/models/message.dart';
import 'package:wechat/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wechat/screens/chat_screen.dart';
import 'package:wechat/widgets/alert_dialog.dart';

import '../helper/date_time.dart';
import '../main.dart';

class HomeCard extends StatefulWidget {
  final ChatUser user;
  const HomeCard({super.key, required this.user});

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onLongPress: () {
          showDialog(context: context, builder: (_) => AlertDialog(

            title:  Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text("cancel")),
                InkWell(
                    onTap: () {
                      Apis.deleteUser(widget.user.email);
                      Navigator.pop(context);
                    },
                    child: const Text("delete")),
              ],
            ),
          ));
        },
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(user: widget.user),));
        },
        child:  StreamBuilder(
          stream: Apis.getLastMessages(widget.user),
            builder: (context , snapshot){
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              return ListTile(
                leading: InkWell(

                  onTap: () {
                    showDialog(context: context, builder: (context) => ViewProfileImage(user: widget.user),);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(23),
                    child: CachedNetworkImage(
                      width: mq.height*.055,
                      height: mq.height*.055,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                    ),
                  ),
                ),
                title: Text(widget.user.name),
                subtitle:  Text(
                  _message != null ?
                  _message!.type == Type.image?'Image':
                  _message!.msg : widget.user.about,
                  maxLines: 1,
                ),
                trailing: _message == null
                    ? null
                    : _message!.read.isEmpty &&
                    _message!.fromId != Apis.user.uid?Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                      color: Colors.green.shade400,
                      borderRadius: BorderRadius.circular(5)),
                ):Text(MyDateTime.getDayTime(context: context, time: _message!.sent),style: const TextStyle(color: Colors.black54),),
              );
            })
      ),
    );
  }
}
