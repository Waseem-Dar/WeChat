
import 'package:flutter/material.dart';
import 'package:wechat/helper/date_time.dart';
import 'package:wechat/models/user_model.dart';
import '../main.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ViewProfile extends StatefulWidget {
 final ChatUser user;
  const ViewProfile({super.key, required this.user});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Joined On : ', style:  TextStyle(fontSize: 18, color: Colors.black87),),
          Text(
            MyDateTime.getDayTime(context: context, time: widget.user.createAt,showYear: true),
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: blue,
        title: Text(widget.user.name,style: const TextStyle(color: Colors.white,),),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(

          children: [
            SizedBox(
              width: mq.width,
              height: mq.height * .03,
            ),
            // User Image

                   ClipRRect(
                     borderRadius: BorderRadius.circular(mq.height * .15),
                     child: CachedNetworkImage(
                      width: mq.height * .25,
                      height: mq.height * .25,
                      imageUrl: widget.user.image,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                      const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                  ),
                   ),


            SizedBox(
              height: mq.height * .020,
            ),
            Text(
              widget.user.email,
              style: const TextStyle(fontSize: 20),
            ),


            SizedBox(
              height: mq.height * .030,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "About :",
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  widget.user.about,
                  style: const TextStyle(fontSize: 20,color: Colors.black54),
                ),
              ],
            ),

          ],
        ),
      ),

    );
  }
}


