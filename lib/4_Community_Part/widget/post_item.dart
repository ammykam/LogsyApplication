import 'package:flutter/material.dart';
import 'package:logsy_app/4_Community_Part/provider/group.dart';
import 'package:logsy_app/4_Community_Part/provider/post.dart';
import 'package:logsy_app/4_Community_Part/provider/user.dart';
import 'package:logsy_app/4_Community_Part/screen/post_screen.dart';
import 'package:logsy_app/4_Community_Part/screen/profile_screen.dart';
import 'package:provider/provider.dart';

class PostItem extends StatefulWidget {
  final int uid;
  final int gid;
  final DateTime timeStamp;
  PostItem(this.uid, this.gid, this.timeStamp);

  @override
  _PostItemState createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool _favState = true;
  int _numFav = 200;
  var _isInit = true;
  var _isLoading = false;
  Post postData;
  User postUser;
  Group groupData;

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      final post = Provider.of<PostProvider>(context, listen: false);
      final user = Provider.of<UserProvider>(context, listen: false);
      final group = Provider.of<GroupProvider>(context, listen: false);

      await post
          .getPost(widget.uid, widget.gid, widget.timeStamp.toString())
          .then((value) {
        postData = value as Post;
      });

      await user.getUser(postData.user_uid).then((value) {
        postUser = value as User;
      });
      await group.getGroup(postData.group_gid).then((value) {
        setState(() {
          groupData = value as Group;
          _isLoading = false;
        });
      });
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  String _getDiffTime(DateTime oldTime) {
    final different = DateTime.now().difference(postData.timestamp);
    // year, month, day
    if (different.inDays >= 1) {
      if (different.inDays == 1) {
        return "${different.inDays.toString()} d";
      }
      return "${different.inDays.toString()} d";
    }
    //hour
    else if (different.inHours >= 1) {
      if (different.inHours == 1) {
        return "${different.inHours.toString()} h";
      }
      return "${different.inHours.toString()} h";
    }
    //minutes
    else if (different.inMinutes >= 1) {
      if (different.inMinutes == 1) {
        return "${different.inMinutes.toString()} m";
      }
      return "${different.inMinutes.toString()} m";
    }
    //seconds
    else {
      return "${different.inSeconds.toString()} s";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);

    return _isLoading ||
            postData == null ||
            postUser == null ||
            groupData == null
        ? LinearProgressIndicator(
             minHeight: 0.1, backgroundColor: Colors.teal[500]
          )
        : GestureDetector(
            onTap: () {
              // Navigator.of(context).pushNamed(PostScreen.routeName,
              //     arguments: postData);
            },
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(ProfileScreen.routeName, arguments: [
                              postData.user_uid,
                              user.userFriendStatus(
                                  user.loginUser, postData.user_uid)
                            ]);
                          },
                          child: Container(
                            width: double.infinity,
                            child: IntrinsicWidth(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.teal[300],
                                    backgroundImage: AssetImage(
                                        'assets/avatar/${postUser.imgUrl}'),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${postUser.firstName} ${postUser.lastName}",
                                          style: TextStyle(
                                              color: Colors.teal,
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "Group: ${groupData.name}",
                                          style: TextStyle(
                                            color: Colors.teal,
                                            fontSize: 12,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  // Spacer(),

                                  Text(
                                    "${_getDiffTime(postData.timestamp)}",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),
                        Text(
                          postData.content,
                          softWrap: true,
                          style: TextStyle(color: Colors.grey[600]),
                        ),

                        postData.imgUrl != null && postData.imgUrl != ""
                            ? Column(
                                children: [
                                  SizedBox(height: 20),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey[100],
                                      image: DecorationImage(
                                          image: NetworkImage(postData.imgUrl),
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                ],
                              )
                            : Container(),

                        // Row(
                        //   //mainAxisAlignment: MainAxisAlignment.end,
                        //   children: [
                        //     GestureDetector(
                        //       onTap: () {
                        //         setState(() {
                        //           _favState = !_favState;
                        //         });
                        //         if (_favState) {
                        //           _numFav++;
                        //         } else {
                        //           _numFav--;
                        //         }
                        //       },
                        //       child: Icon(
                        //         _favState
                        //             ? Icons.favorite
                        //             : Icons.favorite_border,
                        //         color: Colors.teal,
                        //       ),
                        //     ),
                        //     SizedBox(width: 5),
                        //     Text(
                        //       _numFav.toString(),
                        //       style: TextStyle(
                        //           color: Colors.teal,
                        //           fontWeight: FontWeight.bold),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10)
              ],
            ),
          );
  }
}
