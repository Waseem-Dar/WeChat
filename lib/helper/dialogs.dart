import 'package:flutter/material.dart';

class Dialogs{


  static void showSnackBar(BuildContext context,String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(duration: const Duration(seconds: 2),
        content: Text(msg)));
  }
 static void showProgressBar(BuildContext context){
    showDialog(context: context, builder: (_)=>const Center(child: CircularProgressIndicator(),));
  }


}