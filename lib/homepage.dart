import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:pinput/pinput.dart';
import 'package:overlay_support/overlay_support.dart';




class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int otp = 1234;
  Random rand = Random();
  bool canEnterOtp = true;
  var channel = IOWebSocketChannel.connect('ws://192.168.194.37/ws');
  TextEditingController otpController = TextEditingController();
  bool newAddress = false;
  String counterText = "";
  TextEditingController ipAddressController = TextEditingController();


  int countIpDots(String ipAddressInput) {
    int count = 0;
    for (int k = 0; k < ipAddressInput.length; k++) {
      if (ipAddressInput[k] == ".") {
        count++;
      }
    }
    return count;
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text("AutobotOrder",style: TextStyle(color: Colors.white),),backgroundColor: Colors.black,),
        body: StreamBuilder(
          stream: channel.stream,
          builder: (context , snap){
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 30,),
                    ZoomTapAnimation(onTap: (){
                      setState(() {
                        newAddress = true;
                      });

                    },child: Container(height: 50,decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.white,),child: Align(alignment: Alignment.center,child: Text("New Address ?",style: TextStyle(color: Colors.black,fontSize: 20),)),),),
                    SizedBox(height: 30,),
                    ZoomTapAnimation(onTap: (){
                      setState(() {
                        otp = rand.nextInt(9000) + 1000;
                        channel.sink.add("0_${otp.toString()}");
                      });

                    },child: Container(height: 100,decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: Colors.blue.shade900,),child: Align(alignment: Alignment.center,child: Text("Order",style: TextStyle(color: Colors.white,fontSize: 30),)),),),


                    Align(
                      child: Container(height: 50,width: 200,
                        decoration: const BoxDecoration(color: Colors.white,borderRadius: BorderRadius.only(bottomRight: Radius.circular(25),bottomLeft: Radius.circular(25)),),
                        child: Align(alignment: Alignment.center,child: Text("Your otp is $otp",style: TextStyle(color: Colors.blue.shade900,fontSize: 20),)),
                      ),
                    ),
                    SizedBox(height: 50,),
                    Text("Enter your otp here :",style: TextStyle(color: Colors.white),),

                      Pinput(
                        length: 4,
                        defaultPinTheme: PinTheme(textStyle: TextStyle(color: Colors.blue.shade900,fontWeight: FontWeight.normal,fontSize: 20),decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(20)),width: 70,height: 70),
                        onCompleted: (input){
                          if(input == otp.toString()){

                            showSimpleNotification(Text("OpeningDoor....",style: TextStyle(fontWeight: FontWeight.bold),),background: Colors.green.shade900 );
                            channel.sink.add("1_${otp.toString()}");

                          }
                          else{
                            showSimpleNotification(Text("Wrong pin , Enter the correct pin",style: TextStyle(fontWeight: FontWeight.bold),),background: Colors.red.shade900 );
                          }
                        },
                      ),

                    SizedBox(height: 50,),
                    ZoomTapAnimation(onTap: (){
                      showSimpleNotification(Text("© 2023 SpeedyByte Services Pvt. Ltd. All rights reserved.",style: TextStyle(fontWeight: FontWeight.normal,color: Colors.white,fontSize: 15),),background: Colors.black,position: NotificationPosition.bottom,duration: const Duration(seconds: 5));
                    },child: Container(width: 300,height: 300,child: Image.asset("image/logo.png"),))



                  ],
                ),
              ),
            );
          },
        ),


      ),
        if(newAddress) Scaffold(
          backgroundColor: Colors.black.withOpacity(0.8),
          appBar: AppBar(title: IconButton(onPressed: (){
            setState(() {
              newAddress = false;
            });
          }, icon: Icon(Icons.close)),),
          body: TextField(
            controller: ipAddressController,
            keyboardType: TextInputType.number,
            maxLength: 15,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelStyle: const TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic),
              labelText: 'New ip Address',
              counterText: counterText,
              counterStyle: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onChanged: (value) {
              // You can add further validation or processing here
              if (countIpDots(
                  ipAddressController.text.toString()) <
                  3) {
                setState(() {
                  counterText = "please enter a valid ip address";
                });
              } else {
                setState(() {
                  counterText = "";
                });
              }
            },
            onSubmitted: (value){
              setState(() {
                newAddress = false;
                channel = IOWebSocketChannel.connect('ws://${ipAddressController.text.toString()}/ws');
                ipAddressController.clear();
              });
            },
          ),
        ),


      ]
    );
  }

  }
