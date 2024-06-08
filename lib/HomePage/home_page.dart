// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/Local%20Server/localSever.dart';
import 'package:smart_home/auth/create_account.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _subscribeToTopic();
  }

  void _subscribeToTopic() {
    _firebaseMessaging.subscribeToTopic('home');
    print("Subed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeadingH1(heading: "Nimmala's Home,"),
            InkWell(
              onTap: () {

              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeadingH2(heading: "My Desk"),
                    SizedBox(
                      height: 75,
                      width: double.infinity,
                      child: ListView.builder(
                        padding: EdgeInsets.only(bottom: 5),
                          scrollDirection: Axis.horizontal,
                          itemCount: 2,
                          shrinkWrap: true,
                          itemBuilder: (context, int index) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                                  margin: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                                  decoration: BoxDecoration(
                                      color: Colors.white10,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: index==0?Icon(Icons.light_outlined,color: Colors.white60,size: 30,):Icon(Icons.lightbulb,color: Colors.white60,size: 30,),
                                ),
                                Text( index==0?"Main Led":"Studio Lights",style: TextStyle(color: Colors.white,fontSize: 12),)
                              ],
                            );
                          }),
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {

              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                padding: EdgeInsets.only(left: 10,right: 10,bottom: 10),
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.camera_alt_outlined,color: Colors.orangeAccent,),
                        HeadingH2(heading: "Main Door Camera"),
                        Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_sharp,
                          color: Colors.white60,
                          size: 15,
                        )
                      ],
                    ),
                    Text("Last Uploaded on 2 hours ago",style: TextStyle(color: Colors.white70,fontSize: 15),)
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FileManagementScreen()));
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HeadingH2(heading: "Home Files Storage"),
                    Icon(
                      Icons.arrow_forward_ios_sharp,
                      color: Colors.white60,
                      size: 15,
                    )
                  ],
                ),
              ),
            ),
            Center(
                child: Text(
              "Subscribed",
              style: TextStyle(color: Colors.white),
            ))
          ],
        ),
      ),
    );
  }
}
