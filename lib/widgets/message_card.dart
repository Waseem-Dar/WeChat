import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat/helper/apis.dart';
import 'package:wechat/helper/date_time.dart';
import 'package:wechat/models/message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gallery_saver/gallery_saver.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import '../models/user_model.dart';

class MessageCard extends StatefulWidget {
  final Message message;
  final ChatUser user;
  const MessageCard({super.key, required this.message, required this.user});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = Apis.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        showBottom(isMe);
      },
      child: isMe ? greenMessage() : blueMessage(),
    );
  }

  Widget blueMessage() {
    if (widget.message.read.isEmpty) {
      Apis.getMessageReadTime(widget.message);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    width: 20,
                    height: 20,
                    imageUrl: widget.user.image,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                          topRight: Radius.circular(12)),
                      color: Colors.blue.shade200,
                    ),
                    child: widget.message.type == Type.text
                        ? Text(
                            widget.message.msg,
                            style: const TextStyle(fontSize: 16),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CachedNetworkImage(
                              placeholder: (context, url) => const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              imageUrl: widget.message.msg,
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                    child: Icon(Icons.person),
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              MyDateTime.getFormattedTime(
                  context: context, time: widget.message.sent),
            ),
          )
        ],
      ),
    );
  }

  Widget greenMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (widget.message.read.isEmpty)
                const Icon(
                  Icons.done,
                  color: Colors.grey,
                  size: 20,
                ),
              if (widget.message.read.isNotEmpty)
                const Icon(
                  Icons.done_all_rounded,
                  color: Colors.blue,
                  size: 20,
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(MyDateTime.getFormattedTime(
                    context: context, time: widget.message.sent)),
              ),
            ],
          ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
                color: Colors.green.shade200,
              ),
              child: widget.message.type == Type.text
                  ? Text(
                      widget.message.msg,
                      style: const TextStyle(fontSize: 16),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        imageUrl: widget.message.msg,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.person),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void showBottom(bool isMe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20))),
      builder: (context) {
        return ListView(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * .02,
              bottom: MediaQuery.of(context).size.height * .02),
          shrinkWrap: true,
          children: [
            Container(
              height: 8,
              margin: EdgeInsets.symmetric(horizontal: mq.width * .4),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(5)),
            ),
            widget.message.type == Type.text
                ? _OptionItem(
                    icon: const Icon(Icons.copy_all_rounded),
                    name: "Text Copy",
                    onTap: () async {
                      await Clipboard.setData(
                              ClipboardData(text: widget.message.msg))
                          .then((value) {
                        Navigator.pop(context);
                        Dialogs.showSnackBar(context, "Text copied!");
                        FocusScope.of(context).unfocus();
                      });
                    },
                  )
                : _OptionItem(
                    icon: const Icon(Icons.save_alt_rounded),
                    name: "Save Image",
                    onTap: () async {
                      try {
                        Navigator.pop(context);
                        await GallerySaver.saveImage(widget.message.msg,
                            albumName: "WeChat");
                      } catch (e) {
                        log("ERROR $e");
                        Navigator.pop(context);
                      }
                    },
                  ),
            if (widget.message.type == Type.text && isMe)
              _OptionItem(
                icon: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
                name: "Edit",
                onTap: () async {
                  Navigator.pop(context);
                  showUpdateDialog();
                },
              ),
            if (isMe && widget.message.type == Type.text) const Divider(),
            if (isMe)
              _OptionItem(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                name: "Delete",
                onTap: () async {
                  Navigator.pop(context);
                  await Apis.deleteMessages(widget.message).then((value) {});
                },
              ),
            const Divider(),
            _OptionItem(
              icon: const Icon(
                Icons.remove_red_eye_outlined,
                color: Colors.blue,
              ),
              name: "Sent At",
              onTap: () {},
            ),
            _OptionItem(
              icon: const Icon(
                Icons.remove_red_eye_outlined,
                color: Colors.green,
              ),
              name: "Read At",
              onTap: () {},
            ),
          ],
        );
      },
    );
  }

  void showUpdateDialog() {
    String updateMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: const Text("Update Message"),
            content: TextFormField(
              onChanged: (value) => updateMsg = value,
              initialValue: updateMsg,
              cursorColor: Colors.grey,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: blue)),
              ),
            ),
            actions: [
              MaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(color: blue),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Apis.updateMessages(widget.message, updateMsg);
                  Navigator.pop(context);
                },
                child: Text(
                  "Update",
                  style: TextStyle(color: blue),
                ),
              )
            ],
          );
        });
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '   $name',
              style: const TextStyle(fontSize: 18),
            ))
          ],
        ),
      ),
    );
  }
}
