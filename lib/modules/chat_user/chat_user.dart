import 'package:chat_app/modules/chat_user/cubit/cubit.dart';
import 'package:chat_app/shared/components/componenets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/states.dart';

class ChatUserScreen extends StatelessWidget {
  String id;

  ChatUserScreen({this.id});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        return ChatUserCubit()..getData(id);
      },
      child: BlocConsumer<ChatUserCubit, ChatUserStates>(
        listener: (BuildContext context, state) {},
        builder: (BuildContext context, state) {
          ChatUserCubit.get(context).getMyData();
          ChatUserCubit.get(context).getMessages();
          Map data = ChatUserCubit.get(context).data;
          List messages = ChatUserCubit.get(context).messages;
          var messageController = ChatUserCubit.get(context).messageController;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              titleSpacing: 0.0,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 25.0,
                    backgroundImage: NetworkImage(data['image'] ??
                        'https://cdn.icon-icons.com/icons2/1378/PNG/512/avatardefault_92824.png'),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data['first_name']} ${data['last_name']}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                        ),
                        Text(
                          '${data['status']} ',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.video_call),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser.uid)
                          .collection('chats')
                          .doc(data['id'])
                          .collection('messages')
                          .orderBy('full_time', descending: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        return ListView.builder(
                          itemBuilder: (BuildContext context, int index) {
                            if (messages[index]['sender_id'] ==
                                FirebaseAuth.instance.currentUser.uid)
                              return senderBuildItem(messages[index]);
                            else {
                              return receiverBuildItem(messages[index]);
                            }
                          },
                          itemCount: messages.length,
                          shrinkWrap: true,
                        );
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.emoji_emotions_outlined),
                                onPressed: () {},
                              ),
                              Expanded(
                                  child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    showToast(
                                        text: 'Please Enter a message ....');
                                  }
                                  return value;
                                },
                                controller: messageController,
                                style: TextStyle(height: 1.5),
                                onChanged: (s) {
                                  ChatUserCubit.get(context).changeIcon(s);
                                },
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Type a message'),
                              )),
                              IconButton(
                                icon: Icon(Icons.camera_alt_outlined),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Column(
                        children: [
                          FloatingActionButton(
                            heroTag: 'btn1',
                            onPressed: () {
                              ChatUserCubit.get(context).start(context: context);
                              ChatUserCubit.get(context).createChat();
                            },
                            child: Icon(Icons.mic),
                          ),
                          FloatingActionButton(
                            heroTag: 'btn2',

                            onPressed: () {
                              ChatUserCubit.get(context).stop();
                            },
                            child: Icon(Icons.stop),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
