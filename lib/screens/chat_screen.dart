import 'dart:developer';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat/helper/date_time.dart';
import 'package:wechat/main.dart';
import 'package:wechat/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wechat/screens/viwe_profile.dart';
import 'package:wechat/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../helper/apis.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  bool showEmoji = false,isUploading = false;
  final messageController = TextEditingController();
  List<Message> _list = [];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if(showEmoji){
            setState(() {
              showEmoji = !showEmoji;
            });
            return Future.value(false);
          }else{
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: blue,
            flexibleSpace: _appBar(),
          ),
          backgroundColor: const Color.fromARGB(255, 234, 248, 255),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: Apis.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(child: SizedBox());
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                              ?.map((e) => Message.fromJson(e.data()))
                              .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _list.length,
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                    user: widget.user,
                                    message: _list[index],
                                  );
                                });
                          } else {
                            return const Center(
                                child: Text(
                                  "Say Hi 👏!",
                                  style: TextStyle(fontSize: 20),
                                ));
                          }
                      }
                    }),
              ),
              if(isUploading)
              const Align(
                alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(),
                  )),
              bottomBar(),
              if(showEmoji)
              SizedBox(
                height: mq.height *.35,
                child: EmojiPicker(
                  textEditingController: messageController,
                  config: Config(
                    columns: 8,
                    bgColor: const Color.fromARGB(255, 234, 248, 255),
                    emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfile(user: widget.user),));
      },
      child: SafeArea(
        child: StreamBuilder(
          stream: Apis.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                    [];
            return Row(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back,color: Colors.white,)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: CachedNetworkImage(
                    width: 40,
                    height: 40,
                    imageUrl:
                    list.isNotEmpty ? list[0].image : widget.user.image,
                    errorWidget: (context, url, error) =>
                    const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                          ? "Online"
                          : MyDateTime.getLastActiveTime(
                          context: context,
                          lastActive: list[0].lastActive)
                          : MyDateTime.getLastActiveTime(
                          context: context,
                          lastActive: widget.user.lastActive),
                      style: const TextStyle(
                          fontSize: 14, color: Colors.white),
                    ),
                  ],
                )
              ],
            );
          },
        )),
      );

  }

  Widget bottomBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        children: [
          Expanded(
              child: Card(child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        showEmoji = !showEmoji;
                      });
                    },
                    icon: const Icon(
                      Icons.emoji_emotions_rounded,
                      color: Colors.grey,
                      size: 26,
                    )),
                Expanded(
                    child: TextFormField(
                      onTap: () {
                        if(showEmoji){
                          setState(() {
                            showEmoji = !showEmoji;
                          });
                        }
                      },

                      controller: messageController,
                  cursorColor: Colors.grey,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(

                      hintText: "Message", border: InputBorder.none),
                )),
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera,imageQuality: 70);
                      if (image != null) {
                        setState(() => isUploading = true);
                      await Apis.sendChatImage(widget.user, File(image.path));
                        setState(() => isUploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.grey,
                      size: 26,
                    )),
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> images =
                          await picker.pickMultiImage(imageQuality: 70);
                      for (var i in images) {
                        log("images path ${i.path}");
                        setState(() => isUploading = true);
                        await Apis.sendChatImage(widget.user, File(i.path));
                        setState(() => isUploading = false);

                      }
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.grey,
                      size: 26,
                    )),
              ],
            ),
          )),
          MaterialButton(
            padding:
                const EdgeInsets.only(left: 15, right: 10, bottom: 10, top: 10),
            minWidth: 0,
            shape: const CircleBorder(),
            color: Colors.green,
            onPressed: () {
              if(messageController.text.isNotEmpty){
                if(_list.isEmpty){
                  Apis.sendFirstMessage(widget.user, messageController.text,Type.text);
                }else{
                Apis.sendMessage(widget.user, messageController.text,Type.text);
               }
                messageController .clear();
              }
            },
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 30,
            ),
          )
        ],
      ),
    );
  }
}


