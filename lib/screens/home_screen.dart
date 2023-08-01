import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/main.dart';
import 'package:wechat/screens/profile_screen.dart';
import '../helper/apis.dart';
import '../models/user_model.dart';
import '../widgets/home_card.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    Apis.getSelfInfo();

    // Apis.updateActiveStatus(true);
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Messages $message');
      if (Apis.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          Apis.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          Apis.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: blue,
            title: _isSearching
                ? TextFormField(
              onChanged: (val) => {
                _searchList.clear(),
                for (var i in _list){
                  if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                      i.email.toLowerCase().contains(val.toLowerCase())){
                    _searchList.add(i),
                  }},
                setState(() {
                  _searchList;
                })
              },
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              cursorHeight: 18,
              cursorWidth: 1,
              cursorColor: Colors.grey,
              decoration: const InputDecoration(

                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
                hintText: 'Name,Email...',
              ),
            )
                : const Text("We Chat",style: TextStyle(color: Colors.white),),
            leading: const Icon(
              Icons.home,
              color: Colors.white,
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(
                    _isSearching ? Icons.clear_rounded : Icons.search,
                    color: Colors.white,
                  )),
              IconButton(
                  onPressed: () {
                   Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(user: Apis.me),));
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  )),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton(
              backgroundColor: blue,
              onPressed: ()  {
                _addUserDialog();
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          body:StreamBuilder(
            stream: Apis.getMyUsersId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  if(snapshot.hasData) {
                    return StreamBuilder(
                        stream: Apis.getAllUser(snapshot.data?.docs.map((e) =>
                        e.id)
                            .toList() ??[]),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return const Center(
                                  child: CircularProgressIndicator());
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              _list = data?.map((e) =>
                                  ChatUser.fromJson(e.data()))
                                  .toList() ??
                                  [];

                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount:
                                    _isSearching ? _searchList.length : _list
                                        .length,
                                    itemBuilder: (context, index) {
                                      return HomeCard(
                                          user: _isSearching
                                              ? _searchList[index]
                                              : _list[index]);
                                      // return Text("Name : ${list[index]}");
                                    });
                              } else {
                                return const Center(
                                    child: Text(
                                      "No user found !",
                                      style: TextStyle(fontSize: 20),
                                    ));
                              }
                          }
                        });
                  }else{
                    return const Center(
                        child: Text(
                          "No user found !",
                          style: TextStyle(fontSize: 20),
                        ));
                  }
              }
            },),
        ),
      ),
    );
  }
  void _addUserDialog(){
    String email = '';
    showDialog(context: context, builder: (_) => AlertDialog(
      contentPadding: const EdgeInsets.only(left: 24,right: 24,top: 20,bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title:  Row(
        children:[
          Icon(Icons.person_add,color: blue,),
          const Text("  Add User")
        ],
      ),
      content: TextFormField(
        maxLines: null,
        onChanged: (value)=> email = value,
        decoration: InputDecoration(
          hintText: 'Email',
          prefixIcon:  Icon(Icons.email,color: blue,),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15),borderSide: BorderSide(color: blue)),
        ),
      ),
      actions: [
        MaterialButton(onPressed: (){
          Navigator.pop(context);
        },
          child:  Text("Cancel",style: TextStyle(color: blue,fontSize: 16)),
        ),
        MaterialButton(onPressed: () async {
          Navigator.pop(context);
          if(email.isNotEmpty) {
             await Apis.addUser(email).then((value) {
               if(!value) {
                 Dialogs.showSnackBar(context, "User not found");
               }
             });
          }
        },
          child:  Text(" Add",style: TextStyle(color: blue,fontSize: 16)),
        ),
      ],
    ));
  }
}
