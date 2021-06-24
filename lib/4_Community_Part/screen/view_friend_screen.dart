import 'package:flutter/material.dart';
import 'package:logsy_app/4_Community_Part/provider/user.dart';
import 'package:logsy_app/4_Community_Part/screen/profile_screen.dart';
import 'package:logsy_app/4_Community_Part/widget/view_friend_item.dart';
import 'package:provider/provider.dart';

class ViewFriendScreen extends StatefulWidget {
  static const routeName = "/view-friend-screen";

  @override
  _ViewFriendScreenState createState() => _ViewFriendScreenState();
}

class _ViewFriendScreenState extends State<ViewFriendScreen> {
  List<dynamic> _realFriend;
  List<dynamic> _friend;
  var _isLoading = false;
  var currentUid;
  var _isInit = true;
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      currentUid = ModalRoute.of(context).settings.arguments as int;
      final user = Provider.of<UserProvider>(context, listen: false);

      await user.userFriend(currentUid).then((value) {
        setState(() {
          _isLoading = false;
          _realFriend = value;
        });
        _friend = _realFriend;
      });

    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Friends",
          style: TextStyle(
            fontSize: 18,
            color: Colors.teal[500],
            fontWeight: FontWeight.bold
          ),
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.teal),
      ),
      body: _isLoading
          ? Container()
          : Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.07,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.teal[100],
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: TextFormField(
                      onChanged: (text) {
                        if (text == "") {
                          setState(() {
                            _friend = _realFriend;
                          });
                        } else {
                          List<dynamic> searchFriend = _friend
                              .where((element) => '${element['firstName']} ${element['lastName']}'
                                  .toLowerCase()
                                  .contains(text.toLowerCase()))
                              .toList();
                          setState(() {
                            _friend = searchFriend;
                          });
                        }
                      },
                      style: TextStyle(color: Colors.teal),
                      cursorColor: Colors.teal,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          icon: Icon(Icons.search),
                          border: InputBorder.none,
                          focusColor: Colors.teal),
                    ),
                  ),
                ),
                _friend == null
                    ? Container()
                    : Expanded(
                        child: ListView.builder(
                          itemBuilder: (ctx, i) => GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  ProfileScreen.routeName,
                                  arguments: [
                                    _friend[i]['uid'],
                                    user.userFriendStatus(
                                        currentUid, _friend[i]['uid'])
                                  ]);
                            },
                            child: ViewFriendItem(_friend[i]['uid']),
                          ),
                          itemCount: _friend.length,
                        ),
                      ),
              ],
            ),
    );
  }
}
