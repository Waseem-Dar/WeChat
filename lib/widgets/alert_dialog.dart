import 'package:flutter/material.dart';
import 'package:wechat/models/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wechat/screens/viwe_profile.dart';
import '../main.dart';

class ViewProfileImage extends StatelessWidget {
  final ChatUser user;
  const ViewProfileImage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        height: mq.height * .4,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.width* .3),
                child: CachedNetworkImage(
                  width: mq.width*.6,
                  // height: mq.height*.055,
                  imageUrl: user.image,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              width:mq.width*.5,
                child: Text(user.name,style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 17),)),
            Positioned(
              // top: 10,
              right: 5,
              child: MaterialButton(
                minWidth: 0,
                padding: const EdgeInsets.all(0),
                shape: const CircleBorder(),
                onPressed: (){
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfile(user: user),));
                },
               child:  Icon(Icons.info_outline,color: blue,size: 30,),),
            )
          ],
        ),
      ),
    );
  }
}
