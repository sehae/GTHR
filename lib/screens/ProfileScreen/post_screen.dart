import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../models/user_posts.dart';
import '../../services/database.dart';
import '../../shared/custom_scrollbar.dart';
import '../../shared/loading.dart';

class PostScreen extends StatelessWidget {
  final Post post;

  const PostScreen({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<myUser?>(context);
    return StreamBuilder(
        stream: DatabaseService(uid: user?.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData? userData = snapshot.data;
            return Content(user: user, userData: userData, post: post);
          } else {
            return const Loading();
          }
        });
  }
}

class Content extends StatefulWidget {
  final myUser? user;
  final UserData? userData;
  final Post post;

  const Content(
      {Key? key,
      required this.user,
      required this.userData,
      required this.post})
      : super(key: key);

  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.chevron_left),
          ),
          title: const Text(
            'Post',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
            children: [
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: CustomScrollbar(
                    child: Column(
                      children: <Widget>[
                        buildUser(),
                        buildPostContent(),
                        buildReplies(),
                      ],
                    ),
                  ),
                ),
              ),
              _buildReplyInput(),
            ]
        ),
      ),
    );
  }

  Widget _buildReplyInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Post your reply",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, TextEditingValue value, _) {
              if (value.text.isNotEmpty) {
                return IconButton(
                  icon: const Icon(
                      Icons.send,
                    color: Color(0xFF1E7251),
                  ),
                  onPressed: () {

                  },
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildUser() {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF1E7251),
        backgroundImage: widget.userData?.icon != null
            ? MemoryImage(base64Decode(widget.userData!.icon))
            : null,
        radius: 25,
        child: (widget.userData?.icon != null &&
            widget.userData?.icon == '')
            ? Text(
          widget.userData?.fname[0].toUpperCase() ?? '',
          style: const TextStyle(
            fontSize: 16.0,
            color: Colors.white,
          ),
        )
            : null,
      ),
      title: Text('${widget.userData?.fname} ${widget.userData!.lname}'),
      subtitle: Text('@${widget.userData?.username}'),
    );
  }

  Widget buildPostContent() {
    return ListTile(
      title: Text(widget.post.content),
      subtitle:
          Text(DateFormat('h:mm a . M/d/yy').format(widget.post.timestamp)),
    );
  }

  Widget buildReplies() {
    return const ListTile(
      title: Text('Replies'),
    );
  }
}
