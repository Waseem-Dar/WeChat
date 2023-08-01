import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wechat/helper/apis.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/screens/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500),(){
      setState(() {
        _isAnimate= true;
      });
    });
  }
  createUser(){
    Dialogs.showProgressBar(context);
    signInWithGoogle().then((user) async {
      Navigator.pop(context);
     if(user != null){
       log("user${user.credential}");
       log("user${user.additionalUserInfo}");
       if( ( await Apis.userExists())){
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen(),));
       }else{
         Apis.createUser().then((value) {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen(),));
         });
       }
     }
    });
  }
  Future<UserCredential?> signInWithGoogle() async {
    try{
      await InternetAddress.lookup("google.com");
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await Apis.auth.signInWithCredential(credential);
    }catch(e){
      log("SIGNING $e");
      Dialogs.showSnackBar(context, "Please check internet connection");
      return null;
    }
  }
  @override
  Widget build(BuildContext context) {
   mq = MediaQuery.of(context).size;
   blue= const Color.fromARGB(250, 9, 12, 156);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Welcome To We Chat",style: TextStyle(color: Colors.white)),
        backgroundColor:blue,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
              top: mq.height * .05,
              width: mq.width * .6,
              right:_isAnimate? mq.width* .2 : -mq.width*.100,
              duration: const Duration(seconds: 1),
              child: Image.asset("assets/images/ii.png")),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width * .8,
              left: mq.width* .1,
              height: mq.height* .06,
              child: ElevatedButton.icon(

                style: ElevatedButton.styleFrom(backgroundColor: blue,
                shape: const StadiumBorder(),
                ),
                icon: Image.asset("assets/images/google.png",height: mq.height* .04,),
                label: const Text("Sign in with Google",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                onPressed:(){
                  createUser();
                } ,
              )
          ),
        ],
      ),
    );
  }

}
