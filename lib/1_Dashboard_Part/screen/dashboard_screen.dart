import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:logsy_app/1_Dashboard_Part/provider/analyticsMsg.dart';
import 'package:logsy_app/1_Dashboard_Part/screen/lifestyle_summary.dart';
import 'package:logsy_app/1_Dashboard_Part/widget/badge_card.dart';
import 'package:logsy_app/3_Record_Part/provider/lifeStyle.dart';
import 'package:logsy_app/4_Community_Part/provider/badges.dart';
import 'package:logsy_app/4_Community_Part/provider/user.dart';
import 'package:logsy_app/4_Community_Part/screen/profile_screen.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../widget/data_card.dart';

class DashboardScreen extends StatefulWidget {
  static const routeName = '/record';

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String time = "";
  var _isInit = true;
  var _isLoading = false;
  var user;
  var person;
  Badge currentBadge;
  LifeStyle lifeStyle;
  AnalyticsMsg analyticsMsg;
  final controller = PageController(viewportFraction: 0.8);
  DateTime startDateLifeStyle;
  DateTime endDateLifeStyle;

  List<int> _ran = [0, 1];
  List<String> _encourageFood = [
    "Eating healthy is good for your health!",
    "Eat fast food less often. When you visit a fast food restaurant, try the healthful options offered",
    "Eat at least 5 fruits and vegetables a day",
    "Drink 0 sugar-sweetened drinks.",
    "Replace soda pop, sports drinks, and even 100 percent fruit juice with milk or water.",
    "Eat more fish, including a portion of oily fish",
    "Eat lots of fruit and veg",
    "Cut down on saturated fat and sugar",
    "Eat less salt: no more than 6g a day for adults",
    "Do not get thirsty",
    "Do not skip breakfast",
    "Add Greek Yogurt to Your Diet",
    "Eat Eggs, Preferably for Breakfast",
    "Increase Your Protein Intake",
    "Drink Enough Water",
    "Replace Your Favorite “Fast Food” Restaurant",
    "Try at Least One New Healthy Recipe Per Week",
    "Eat Your Greens First",
    "Eat Your Fruits Instead of Drinking Them",
  ];
  List<String> _encourageSleep = [
    "Stick to a sleep schedule",
    "Pay attention to what you eat and drink",
    "Create a restful environment",
    "Limit daytime naps",
    "Include physical activity in your daily routine",
    "Manage worries"
  ];
  List<String> _encourageExer = [
    "Remember to warm-up",
    "Include strength training",
    "Include carbs in a pre-workout snack",
    "Focus on hydration",
    "Make sleep a priority",
    "Train with a friend",
    "Include protein and healthy fats in your meals",
    "Listen to your body",
    "Allow time to rest",
    "Be consistent",
    "Add some motivating workout music",
    "Make exercise a priority — no excuses",
  ];

  @override
  void didChangeDependencies() async {
    if (_isInit) {
      user = Provider.of<UserProvider>(context, listen: false);

      final lifestyle = Provider.of<LifeStyleProvider>(context, listen: false);
      final analytics =
          Provider.of<AnalyticsMsgProvider>(context, listen: false);
      DateTime now = DateTime.now();
      startDateLifeStyle = now.weekday == 7
          ? now.subtract(Duration(days: 7))
          : now
              .subtract(Duration(days: now.weekday))
              .subtract(Duration(days: 7));
      endDateLifeStyle = now.weekday == 7
          ? now.add(Duration(days: 6)).subtract(Duration(days: 7))
          : now
              .subtract(Duration(days: now.weekday - 6))
              .subtract(Duration(days: 7));

      //of last week

      if (DateFormat("EEEE").format(DateTime.now()) == "Sunday") {
        await lifestyle
            .getLifeStyle(user.loginUser, startDateLifeStyle, endDateLifeStyle)
            .then((value) {
          lifeStyle = value;
        });
      }

      await analytics
          .getDashboardMessage(user.loginUser, startDateLifeStyle)
          .then((value) {
        if (value == null) {
          analyticsMsg = AnalyticsMsg(uid: 0);
        } else {
          analyticsMsg = value;
        }
      });

      await user.getUser(user.loginUser).then(
        (value) {
          setState(() {
            _isLoading = false;
            person = value as User;
          });
        },
      );
      final hour = DateTime.now().hour;
      if (hour < 12) {
        time = "Good Morning";
      } else if (hour < 18) {
        time = "Good Afternoon";
      } else {
        time = "Good Evening";
      }
      setState(() {});
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void fetchAndSetData() async {
    final user = Provider.of<UserProvider>(context, listen: false);
    await user.getUser(user.loginUser).then(
      (value) {
        setState(() {
          person = value as User;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int show = _ran[Random().nextInt(_ran.length)];
    String sleep = _encourageSleep[Random().nextInt(_encourageSleep.length)];
    String exercise = _encourageExer[Random().nextInt(_encourageExer.length)];
    String food = _encourageFood[Random().nextInt(_encourageFood.length)];

    return Scaffold(
      body: analyticsMsg == null || person == null
          ? LinearProgressIndicator(
              color: Colors.teal[200],
            )
          : Container(
              
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/Dashboard.png"),
                  fit: BoxFit.fitHeight,

                ),
                color: Color.fromRGBO(236, 234, 208, 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0.0,
                    flexibleSpace: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05,
                          left: MediaQuery.of(context).size.height * 0.05,
                          right: MediaQuery.of(context).size.height * 0.05),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  ProfileScreen.routeName,
                                  arguments: [
                                    person.uid,
                                    "Owner"
                                  ]).then((value) {
                                fetchAndSetData();
                              });
                            },
                            child: Material(
                              shape: CircleBorder(),
                              elevation: 4.0,
                              child: Container(
                                width: 80,
                                height: 80,
                                margin: EdgeInsets.only(bottom: 0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "assets/avatar/${person.imgUrl}"),
                                      fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                time == "" ? "" : "${time}, ",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                person == null ? "" : "${person.firstName}",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color.fromRGBO(151, 112, 213, 1),
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                " !",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            'Today is ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.45,
                        //width: MediaQuery.of(context).size.width,
                        child: PageView(
                          controller: controller,
                          children: [
                            DataCard(analyticsMsg, "Eat", startDateLifeStyle,
                                endDateLifeStyle, show, food),
                            DataCard(analyticsMsg, "Sleep", startDateLifeStyle,
                                endDateLifeStyle, show, sleep),
                            DataCard(
                                analyticsMsg,
                                "Exercise",
                                startDateLifeStyle,
                                endDateLifeStyle,
                                show,
                                exercise),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: SmoothPageIndicator(
                          controller: controller,
                          count: 3,
                          effect: WormEffect(
                              dotWidth: 8,
                              dotHeight: 8,
                              dotColor: Colors.grey[400],
                              activeDotColor: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

// class _DashboardScreenState extends State<DashboardScreen> {
//   String msg;
//   Color color1;
//   Color color2;
//   String time = "";

//   var _isInit = true;
//   var _isLoading = false;
//   var user;
//   var person;
//   Badge currentBadge;
//   LifeStyle lifeStyle;
//   AnalyticsMsg analyticsMsg;

//   final String topMessage1 = "What you did this week is splendid!";
//   final String description =
//       "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
//   List<int> _ran = [0, 1];
//   final controller = PageController(viewportFraction: 0.8);

//   List<String> _encourageSleep = [
//     "Stick to a sleep schedule",
//     "Pay attention to what you eat and drink",
//     "Create a restful environment",
//     "Limit daytime naps",
//     "Include physical activity in your daily routine",
//     "Manage worries"
//   ];

//   List<String> _encourageExer = [
//     "Remember to warm-up",
//     "Include strength training",
//     "Include carbs in a pre-workout snack",
//     "Focus on hydration",
//     "Make sleep a priority",
//     "Train with a friend",
//     "Include protein and healthy fats in your meals",
//     "Listen to your body",
//     "Allow time to rest",
//     "Be consistent",
//     "Add some motivating workout music",
//     "Make exercise a priority — no excuses",
//   ];

//   @override
//   void initState() {
//     setState(() {
//       msg = topMessage1;
//       color1 = Colors.deepPurple[300];
//       color2 = Colors.deepPurple[200];
//     });
//     super.initState();
//   }

//   @override
//   void didChangeDependencies() async {
//     if (_isInit) {
//       user = Provider.of<UserProvider>(context, listen: false);
//       final badge = Provider.of<BadgeProvider>(context, listen: false);
//       final lifestyle = Provider.of<LifeStyleProvider>(context, listen: false);
//       final analytics =
//           Provider.of<AnalyticsMsgProvider>(context, listen: false);
//       DateTime now = DateTime.now();
//       DateTime startDateLifeStyle = now.weekday == 7
//           ? now.subtract(Duration(days: 7))
//           : now
//               .subtract(Duration(days: now.weekday))
//               .subtract(Duration(days: 7));
//       DateTime endDateLifeStyle = now.weekday == 7
//           ? now.add(Duration(days: 6)).subtract(Duration(days: 7))
//           : now
//               .subtract(Duration(days: now.weekday - 6))
//               .subtract(Duration(days: 7));

//       //of last week
//       await lifestyle
//           .getLifeStyle(user.loginUser, startDateLifeStyle, endDateLifeStyle)
//           .then((value) {
//         lifeStyle = value;
//       });
//       await analytics
//           .getDashboardMessage(user.loginUser, startDateLifeStyle)
//           .then((value) {
//         analyticsMsg = value;
//       });
//       // Badge
//       await badge.getNewBadge(user.loginUser).then((value) {
//         currentBadge = value;
//       });

//       await user.getUser(user.loginUser).then(
//         (value) {
//           setState(() {
//             _isLoading = false;
//             person = value as User;
//           });
//         },
//       );
//       final hour = DateTime.now().hour;
//       if (hour < 12) {
//         time = "Good Morning";
//       } else if (hour < 18) {
//         time = "Good Afternoon";
//       } else {
//         time = "Good Evening";
//       }
//       setState(() {});
//     }
//     _isInit = false;

//     super.didChangeDependencies();
//   }

//   void fetchAndSetData() async {
//     final user = Provider.of<UserProvider>(context, listen: false);
//     await user.getUser(user.loginUser).then(
//       (value) {
//         setState(() {
//           person = value as User;
//         });
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     int _show = _ran[Random().nextInt(_ran.length)];
//     String sleep = _encourageSleep[Random().nextInt(_encourageSleep.length)];
//     String exercise = _encourageExer[Random().nextInt(_encourageExer.length)];

//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(children: [
//           lifeStyle == null || analyticsMsg == null || person == null
//               ? LinearProgressIndicator(
//                   color: Colors.teal[200],
//                 )
//               : Stack(
//                   children: [
//                     //color of app bar
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius:
//                             BorderRadius.vertical(bottom: Radius.circular(30)),
//                         color: Color.fromRGBO(57, 184, 150, 1),
//                       ),
//                       height: MediaQuery.of(context).size.height * 0.25,
//                     ),

//                     Column(
//                       children: [
//                         Container(
//                           height: MediaQuery.of(context).size.height * 0.62,
//                           //width: MediaQuery.of(context).size.width,
//                           child: PageView(
//                             controller: controller,
//                             children: [
//                               DataCard(analyticsMsg, Colors.blue[300],
//                                   Colors.orange[300], "Eat"),
//                               DataCard(analyticsMsg, Colors.yellow[300],
//                                   Colors.blue[300], "Sleep"),
//                               DataCard(analyticsMsg, Colors.purple[200],
//                                   Colors.orange[100], "Exercise"),
//                               currentBadge == null
//                                   ? Container()
//                                   : BadgeCard(
//                                       badge: currentBadge,
//                                     ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 10),
//                         Container(
//                           child: SmoothPageIndicator(
//                             controller: controller,
//                             count: 4,
//                             effect: WormEffect(
//                                 dotWidth: 8,
//                                 dotHeight: 8,
//                                 dotColor: Colors.teal[100],
//                                 activeDotColor: Colors.teal),
//                           ),
//                         ),
//                         // SingleChildScrollView(
//                         //   controller: controller,
//                         //   scrollDirection: Axis.horizontal,
//                         //   physics: ClampingScrollPhysics(),
//                         //   child: Row(
//                         //     children: [
//                         //       DataCard(analyticsMsg, Colors.blue[300],
//                         //           Colors.orange[300], "Eat"),
//                         //       DataCard(analyticsMsg, Colors.yellow[300],
//                         //           Colors.blue[300], "Sleep"),
//                         //       DataCard(analyticsMsg, Colors.purple[200],
//                         //           Colors.orange[100], "Exercise"),
//                         //       currentBadge == null
//                         //           ? Container()
//                         //           : BadgeCard(
//                         //               badge: currentBadge,
//                         //             ),
//                         //     ],
//                         //   ),
//                         // ),
//                       ],
//                     ),

//                     //buttons
//                     Container(
//                       padding: EdgeInsets.only(
//                           top: MediaQuery.of(context).size.height * 0.65),
//                       // color: Colors.transparent,
//                       child: Column(
//                         children: [
//                           Text(
//                             "Your LifeStyle",
//                             style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize:
//                                     MediaQuery.of(context).size.height * 0.025,
//                                 fontWeight: FontWeight.bold),
//                             textAlign: TextAlign.center,
//                           ),
//                           //those 3 circle
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Expanded(
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     Navigator.of(context).pushNamed(
//                                         LifeStyleSummary.routeName,
//                                         arguments: 0);
//                                   },
//                                   child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         Container(
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width *
//                                               0.25,
//                                           height: MediaQuery.of(context)
//                                                   .size
//                                                   .height *
//                                               0.15,
//                                           margin: EdgeInsets.only(bottom: 0),
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: lifeStyle.eat == "red"
//                                                 ? Colors.redAccent[100]
//                                                 : Colors.green[300],
//                                             boxShadow: [
//                                               BoxShadow(
//                                                 offset: Offset(2.0, 1.5),
//                                                 blurRadius: 1.0,
//                                                 color: Colors.black12,
//                                               ),
//                                               BoxShadow(
//                                                 offset: Offset(0.5, 0.5),
//                                                 blurRadius: 8.0,
//                                                 color: Colors.black12,
//                                               ),
//                                             ],
//                                           ),
//                                           child: Icon(Icons.food_bank,
//                                               size: 60, color: Colors.white),
//                                         ),
//                                         Text(
//                                           "EAT",
//                                           style: TextStyle(
//                                               fontSize: MediaQuery.of(context)
//                                                       .size
//                                                       .height *
//                                                   0.025,
//                                               fontWeight: FontWeight.bold,
//                                               color: lifeStyle.eat == "red"
//                                                   ? Colors.redAccent[100]
//                                                   : Colors.green[300]),
//                                         )
//                                       ]),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     Navigator.of(context).pushNamed(
//                                         LifeStyleSummary.routeName,
//                                         arguments: 1);
//                                     _show == 1
//                                         ? showOverlayNotification((context) {
//                                             return Column(
//                                               children: [
//                                                 SizedBox(
//                                                     height:
//                                                         MediaQuery.of(context)
//                                                                 .size
//                                                                 .height *
//                                                             0.05),
//                                                 Card(
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             15.0),
//                                                   ),
//                                                   child: Padding(
//                                                     padding: const EdgeInsets
//                                                             .symmetric(
//                                                         vertical: 10),
//                                                     child: ListTile(
//                                                       title: Text(
//                                                         'Wonder about Sleep?',
//                                                         style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .bold),
//                                                       ),
//                                                       subtitle: Text(sleep),
//                                                       trailing: IconButton(
//                                                           icon:
//                                                               Icon(Icons.close),
//                                                           onPressed: () {
//                                                             OverlaySupportEntry
//                                                                     .of(context)
//                                                                 .dismiss();
//                                                           }),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             );
//                                           },
//                                             duration:
//                                                 Duration(milliseconds: 4000))
//                                         : Container();
//                                   },
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Container(
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.25,
//                                         height:
//                                             MediaQuery.of(context).size.height *
//                                                 0.15,
//                                         margin: EdgeInsets.only(bottom: 0),
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: lifeStyle.sleep == "red"
//                                               ? Colors.redAccent[100]
//                                               : lifeStyle.sleep == "yellow"
//                                                   ? Colors.amber[300]
//                                                   : Colors.green[300],
//                                           boxShadow: [
//                                             BoxShadow(
//                                               offset: Offset(2.0, 1.5),
//                                               blurRadius: 1.0,
//                                               color: Colors.black12,
//                                             ),
//                                             BoxShadow(
//                                               offset: Offset(0.5, 0.5),
//                                               blurRadius: 8.0,
//                                               color: Colors.black12,
//                                             ),
//                                           ],
//                                         ),
//                                         child: Icon(Icons.king_bed,
//                                             color: Colors.white, size: 50),
//                                       ),
//                                       Text(
//                                         "SLEEP",
//                                         style: TextStyle(
//                                             fontSize: MediaQuery.of(context)
//                                                     .size
//                                                     .height *
//                                                 0.025,
//                                             fontWeight: FontWeight.bold,
//                                             color: lifeStyle.sleep == "red"
//                                                 ? Colors.redAccent[100]
//                                                 : lifeStyle.sleep == "yellow"
//                                                     ? Colors.amber[300]
//                                                     : Colors.green[300]),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: GestureDetector(
//                                   onTap: () {
//                                     Navigator.of(context).pushNamed(
//                                         LifeStyleSummary.routeName,
//                                         arguments: 2);
//                                     _show == 1
//                                         ? showOverlayNotification((context) {
//                                             return Column(
//                                               children: [
//                                                 SizedBox(
//                                                     height:
//                                                         MediaQuery.of(context)
//                                                                 .size
//                                                                 .height *
//                                                             0.05),
//                                                 Card(
//                                                   shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                         BorderRadius.circular(
//                                                             15.0),
//                                                   ),
//                                                   child: Padding(
//                                                     padding: const EdgeInsets
//                                                             .symmetric(
//                                                         vertical: 10),
//                                                     child: ListTile(
//                                                       title: Text(
//                                                         'Exercise?',
//                                                         style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight
//                                                                     .bold),
//                                                       ),
//                                                       subtitle: Text(exercise),
//                                                       trailing: IconButton(
//                                                           icon:
//                                                               Icon(Icons.close),
//                                                           onPressed: () {
//                                                             OverlaySupportEntry
//                                                                     .of(context)
//                                                                 .dismiss();
//                                                           }),
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                             );
//                                           },
//                                             duration:
//                                                 Duration(milliseconds: 4000))
//                                         : Container();
//                                   },
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       Container(
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.25,
//                                         height:
//                                             MediaQuery.of(context).size.height *
//                                                 0.15,
//                                         margin: EdgeInsets.only(bottom: 0),
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: lifeStyle.exercise == "red"
//                                               ? Colors.redAccent[100]
//                                               : lifeStyle.exercise == "yellow"
//                                                   ? Colors.amber[300]
//                                                   : Colors.green[300],
//                                           boxShadow: [
//                                             BoxShadow(
//                                               offset: Offset(2.0, 1.5),
//                                               blurRadius: 1.0,
//                                               color: Colors.black12,
//                                             ),
//                                             BoxShadow(
//                                               offset: Offset(0.5, 0.5),
//                                               blurRadius: 8.0,
//                                               color: Colors.black12,
//                                             ),
//                                           ],
//                                         ),
//                                         child: Icon(Icons.sports_handball,
//                                             color: Colors.white, size: 50),
//                                       ),
//                                       Text(
//                                         "EXERCISE",
//                                         style: TextStyle(
//                                           fontSize: MediaQuery.of(context)
//                                                   .size
//                                                   .height *
//                                               0.025,
//                                           fontWeight: FontWeight.bold,
//                                           color: lifeStyle.exercise == "red"
//                                               ? Colors.redAccent[100]
//                                               : lifeStyle.exercise == "yellow"
//                                                   ? Colors.amber[300]
//                                                   : Colors.green[300],
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     //App bar
//                     Positioned(
//                       top: 0.0,
//                       left: 0.0,
//                       right: 0.0,
//                       child: AppBar(
//                         // Add AppBar here only
//                         backgroundColor: Colors.transparent,
//                         elevation: 0.0,
//                         flexibleSpace: Padding(
//                           padding: EdgeInsets.only(
//                               top: MediaQuery.of(context).size.height * 0.05,
//                               left: MediaQuery.of(context).size.height * 0.05,
//                               right: MediaQuery.of(context).size.height * 0.05),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       DateFormat('dd MMMM yyyy')
//                                           .format(DateTime.now()),
//                                       textAlign: TextAlign.left,
//                                       style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white),
//                                     ),
//                                     Text(
//                                       person == null || time == ""
//                                           ? ""
//                                           : "${time}, ${person.firstName}!",
//                                       textAlign: TextAlign.left,
//                                       style: TextStyle(
//                                           fontSize: 15, color: Colors.white),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   Navigator.of(context).pushNamed(
//                                       ProfileScreen.routeName,
//                                       arguments: [
//                                         person.uid,
//                                         "Owner"
//                                       ]).then((value) {
//                                     fetchAndSetData();
//                                   });
//                                 },
//                                 child: Material(
//                                   shape: CircleBorder(),
//                                   elevation: 4.0,
//                                   child: Container(
//                                     width: 80,
//                                     height: 80,
//                                     margin: EdgeInsets.only(bottom: 0),
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       image: DecorationImage(
//                                           image: AssetImage(
//                                               "assets/avatar/${person.imgUrl}"),
//                                           fit: BoxFit.cover),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//         ]),
//       ),
//     );
//   }
// }
