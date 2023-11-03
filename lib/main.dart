import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:android_id/android_id.dart';

void main(){
  runApp(MyApp());
  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

String errorTextHolder="";
String errorText="";
String textId="your andriod ID will be shown Here !!!";
String dateTextHolder="Pulse Date";
String lang ="Longitude";
String lat ="Latitude";
String? uuid;

late DateTime? date;
late StreamSubscription _sub;

bool isLive=false;

late Position position;

AndroidId id =const AndroidId();

LocationSettings locationSettings= const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
    );

 @override
  void initState() {
    super.initState();
    getUuid();
    isLive=false;
  }


void  getUuid() async {
  uuid = await id.getId();
  setState(()  {
    textId=uuid!.toUpperCase();
  });
}


Future<Position> _getCurLoc() async{
  bool serviceEnabled=  await Geolocator.isLocationServiceEnabled();
  if(!serviceEnabled){
    setState(() {
        errorText="GPS is off";
        errorTextHolder=errorText;
      });
    return Future.error("GPS is Off");
  }

  LocationPermission permission =await Geolocator.checkPermission();
  if(permission==LocationPermission.denied){
    setState(() {
        errorText="loaction permisson is deined";
        errorTextHolder=errorText;
      });
    permission = await Geolocator.requestPermission();
    if(permission==LocationPermission.denied){
      setState(() {
        errorText="loaction permisson is deined";
        errorTextHolder=errorText;
      });
        return Future.error("loaction permisson is deined");
    }
  }
  if(permission==LocationPermission.deniedForever){
    setState(() {
      errorText="loaction permisson are permently deined";
      errorTextHolder=errorText;
    });
      return Future.error("loaction permisson are permently deined");
    }
    setState(() {
      errorText="";
      errorTextHolder=errorText;
    });
    
    isLive=true;
  return await Geolocator.getCurrentPosition();
}


void _liveLoction(){
    _sub=Geolocator.getPositionStream(locationSettings: locationSettings)
    .listen((position) {
      lat=position.latitude.toString();
      lang=position.longitude.toString();
     setState(() {
      date=position.timestamp;
      errorTextHolder=errorText;
       lat='latitude : $lat';
       lang='longitude : $lang';
       dateTextHolder= 'pulse date ${  date.toString()}';
     });
     });
}
void calLoc (){
  _sub.cancel();
  setState(() {
    isLive=false;
  });
  
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Get LOC App"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(errorTextHolder,style: TextStyle(fontSize: 20),),
            SizedBox(height: 15),
            Text(textId,style: TextStyle(fontSize: 20),),
            SizedBox(height: 15),
            Text(lat ,style: TextStyle(fontSize: 20),),
            SizedBox(height: 15),
            Text(lang ,style: TextStyle(fontSize: 20),),
            SizedBox(height: 15),
            Text(dateTextHolder ,style: TextStyle(fontSize: 20),),
            SizedBox(height: 60),
                if (isLive==true) 
                ElevatedButton(onPressed: calLoc, child:  Text("Stop" ,style: TextStyle(fontSize: 24),) ,
                style: ButtonStyle(shape: MaterialStateProperty.all(CircleBorder()),
                padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                 backgroundColor: MaterialStateProperty.all(Colors.red),
                )
                )
                else
                ElevatedButton(onPressed:  (){
                   _getCurLoc().then((value) {
                  lat= '${value.latitude}';
                  lang ='${value.longitude}';
                  
                  _liveLoction();
                });
                }, child:  Text("Go" ,style: TextStyle(fontSize: 24),) ,
                style: ButtonStyle(shape: MaterialStateProperty.all(CircleBorder()),
                padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                 backgroundColor: MaterialStateProperty.all(Colors.green),
                )
                ),
            ]
        ),
      ),
    );
  }
}