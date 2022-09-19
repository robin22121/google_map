import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final LatLng conpanyLatLng = LatLng(
    37.5233273,
    126.921252,
  );
  static final CameraPosition initialPosition =
      CameraPosition(target: conpanyLatLng, zoom: 15);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppbar(),
      body: FutureBuilder(
        future: checkPermission(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          print(snapshot.data);
          if (snapshot.data == '앱 권한 허가') {
            return Column(
              children: [
                _CuntomGooogleMap(initialPosition: initialPosition),
                _ChekAttendance(),
              ],
            );
          }
          return Center(
            child : Text(snapshot.data)
          );
        },
      ),
    );
  }

  AppBar renderAppbar() {
    return AppBar(
        backgroundColor: Colors.black,
        title: Text(
            '구글지도 사용하기'
            '111',
            style: TextStyle(
                color: Colors.lightBlue, fontWeight: FontWeight.w700)));
  }
}

class _CuntomGooogleMap extends StatelessWidget {
  final CameraPosition initialPosition;
  const _CuntomGooogleMap({required this.initialPosition, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialPosition,
      ),
    );
  }
}

class _ChekAttendance extends StatelessWidget {
  const _ChekAttendance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child:
            Container(margin: EdgeInsets.only(top: 10), child: Text('출근점검')));
  }
}

// Future<String> checkPermission() async{
//   final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
//   if(!isLocationEnabled){
//     return '위치상태창을 켜주세요';
//   }
//   LocationPermission checkPermision = await Geolocator.checkPermission();
// }

Future<String> checkPermission() async {
  final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

  if (!isLocationEnabled) {
    return '위치 서비스를 활성화 해주세요.';
  }

  LocationPermission checkedPermission = await Geolocator.checkPermission();

  if (checkedPermission == LocationPermission.denied) {
    checkedPermission = await Geolocator.requestPermission();
    if (checkedPermission == LocationPermission.denied) {
      return '위치를 켜 주세요';
    }
  }

  if (checkedPermission == LocationPermission.deniedForever) {
    return '앱에서 설정 변경';
  }
  return '앱 권한 허가';
}
