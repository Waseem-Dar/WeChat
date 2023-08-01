import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechat/screens/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../helper/apis.dart';
import '../main.dart';
import '../models/user_model.dart';


class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text(
            "Profile Screen",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: blue,
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Apis.updateActiveStatus(false);
              Dialogs.showProgressBar(context);
              await FirebaseAuth.instance.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ));
                   Apis.auth  = FirebaseAuth.instance;
                });
              });
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: mq.width,
                  height: mq.height * .03,
                ),
                                                                               // User Image
                Stack(
                  children: [
                    _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: Image.file(
                              File(_image!),
                              width: mq.height * .2,
                              height: mq.height * .2,
                              fit: BoxFit.cover,
                            ),
                          )
                        :  ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .1),
                          child: CachedNetworkImage(
                             width: mq.height * .2,
                             height: mq.height * .2,
                             imageUrl: widget.user.image,
                             fit: BoxFit.cover,
                             errorWidget: (context, url, error) =>
                             const CircleAvatar(
                               child: Icon(Icons.person),
                          ),
                        ),
                    ),
                    Positioned(
                            bottom: -5,
                            right: 0,
                            child: MaterialButton(
                              color: Colors.grey.shade300,
                              shape: const CircleBorder(),
                              onPressed: () {
                                showBottomSheet();
                              },
                              child: const Icon(Icons.edit),
                            ),
                          )
                  ],
                ),
                SizedBox(
                  height: mq.height * .020,
                ),
                Text(
                  widget.user.email,
                  style: const TextStyle(fontSize: 20),
                ),
                SizedBox(
                  height: mq.height * .050,
                ),
                                                                              // Name TextField
                TextFormField(
                  onSaved: (val) => Apis.me.name = val ?? "",
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : "Required Field",
                  initialValue: widget.user.name,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(color: blue),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: blue,
                          )),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          )),
                      prefixIcon: Icon(
                        Icons.person,
                        color: blue,
                      )),
                ),
                SizedBox(
                  height: mq.height * .040,
                ),
                                                                                // About TextField
                TextFormField(
                  onSaved: (val) => Apis.me.about = val ?? "",
                  validator: (val) =>
                      val != null && val.isNotEmpty ? null : "Required Field",
                  initialValue: widget.user.about,
                  cursorColor: Colors.grey,
                  decoration: InputDecoration(
                      labelText: "About",
                      labelStyle: TextStyle(color: blue),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 0),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: blue,
                          )),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          )),
                      prefixIcon: Icon(
                        Icons.info_outline,
                        color: blue,
                      )),
                ),
                SizedBox(
                  height: mq.height * .050,
                ),
                                                                                // Update Button
                SizedBox(
                  width: mq.width * .5,
                  height: mq.height * .055,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: blue,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          // log("inside validate");
                          Apis.updateUserInfo().then((value) {
                            Dialogs.showSnackBar(
                                context, "Profile Update Successfully!");
                          });
                        }
                      },
                      child: const Text(
                        "Update",
                        style: TextStyle(fontSize: 22),
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(15), topLeft: Radius.circular(15))),
        builder: (_) {
          return ListView(
            padding: EdgeInsets.all(mq.height * .01),
            shrinkWrap: true,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                                                                                                 // image from gallery
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * .3, mq.width * .3)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                            Apis.updateProfilePicture(File(_image!)).then((value) {   Navigator.pop(context);});
                        }
                      },
                      child: Image.asset("assets/images/gallery.png")),
                                                                                                    // image from camera
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          fixedSize: Size(mq.width * .3, mq.width * .3)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                          Apis.updateProfilePicture(File(_image!)).then((value) { Navigator.pop(context);});

                        }
                      },
                      child: Image.asset("assets/images/camera.png")),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          );
        });
  }
}
