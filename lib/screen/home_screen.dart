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
  bool choolCheckDone = false;
  GoogleMapController? mapController;
  static final LatLng companyLatLng = LatLng(
    37.205396,
    127.108845,
  );
  static final CameraPosition initialPosition =
      CameraPosition(target: companyLatLng, zoom: 15);
  static const double okDistance = 100;
  static final Circle withinDistanceCircle = Circle(
    circleId: CircleId('circle'),
    center: companyLatLng,
    radius: okDistance,
    fillColor: Colors.blue.withOpacity(0.5),
    strokeWidth: 1,
  );
  static final Circle notWithinDistanceCircle = Circle(
    circleId: CircleId('circle'),
    center: companyLatLng,
    radius: okDistance,
    fillColor: Colors.red.withOpacity(0.5),
    strokeWidth: 1,
  );
  static final Circle CheckDoneCircle = Circle(
    circleId: CircleId('circle'),
    center: companyLatLng,
    radius: okDistance,
    fillColor: Colors.green.withOpacity(0.5),
    strokeWidth: 1,
  );
  static final Marker marker =
      Marker(markerId: MarkerId('marker'), position: companyLatLng);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppbar(),
      //FutureBuilder 앱을 실행할때마다 future를 실행하고 return된 값을 snapshot에 답는다.
      body: FutureBuilder(
        future: checkPermission(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          //Connecttionstate의 상태 none, active, waiting, done에 따라 다른 창을 보이게 만들 수 있다.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          print(snapshot.data);
          //return된 snapshot데이터가 데이터 접근 허용일때 지도 맵을 보여
          if (snapshot.data == '앱 권한 허가') {
            return StreamBuilder<Position>(
                //나의 현재위치가 바뀔때마다 새로운 값이 snapshot에 저장
                stream: Geolocator.getPositionStream(),
                builder: (context, snapshot) {
                  bool isWithinRange = false;
                  if (snapshot.hasData) {
                    final start = snapshot.data!;
                    final end = companyLatLng;
                    final distance = Geolocator.distanceBetween(
                        start.latitude,
                        start.longitude,
                        companyLatLng.latitude,
                        companyLatLng.longitude);
                    if (distance < okDistance) {
                      isWithinRange = true;
                    }
                  }
                  print(snapshot.runtimeType);
                  return Column(
                    children: [
                      _CuntomGooogleMap(
                        initialPosition: initialPosition,
                        circle: choolCheckDone
                            ? CheckDoneCircle
                            : isWithinRange
                                ? withinDistanceCircle
                                : notWithinDistanceCircle,
                        marker: marker,
                        onMapCreated: onMapCreated,
                      ),
                      _ChekAttendance(
                        isWithinRange: isWithinRange,
                        onPressed: onChoolCheckPressed,
                        choolCheckDone: choolCheckDone,
                      ),
                    ],
                  );
                });
          }
          return Center(child: Text(snapshot.data));
        },
      ),
    );
  }

  onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  onChoolCheckPressed() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('출근하기'),
          content: Text('출근을 하시겠습니까'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('취소')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('출근하기')),
          ],
        );
      },
    );
    if (result) {
      setState(() {
        choolCheckDone = true;
      });
    }
  }

  AppBar renderAppbar() {
    return AppBar(
        backgroundColor: Colors.black,
        title: Text(
          '구글지도 사용하ss기'
          '111',
          style:
              TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
              color: Colors.blue,
              onPressed: () async {
                if (mapController == null) {
                  return;
                }

                final location = await Geolocator.getCurrentPosition();
                print(  location.latitude);
                mapController!.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(
                      location.latitude,
                      location.longitude,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.my_location,
              ))
        ]);
  }
}

class _CuntomGooogleMap extends StatelessWidget {
  final MapCreatedCallback onMapCreated;
  final CameraPosition initialPosition;
  final Circle circle;
  final Marker marker;
  const _CuntomGooogleMap(
      {required this.onMapCreated,
      required this.initialPosition,
      required this.circle,
      required this.marker,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: initialPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        circles: Set.from([circle]),
        markers: Set.from([marker]),
        onMapCreated: onMapCreated,
      ),
    );
  }
}

class _ChekAttendance extends StatelessWidget {
  final bool isWithinRange;
  final bool choolCheckDone;
  final VoidCallback onPressed;

  const _ChekAttendance(
      {required this.choolCheckDone,
      required this.onPressed,
      required this.isWithinRange,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timelapse_outlined,
            size: 50.0,
            color: choolCheckDone
                ? Colors.green
                : isWithinRange
                    ? Colors.blue
                    : Colors.red),
        SizedBox(height: 20.0),
        if (!choolCheckDone && isWithinRange)
          ElevatedButton(onPressed: onPressed, child: Text('출첵')),
      ],
    ));
  }
}

// permisstion의 상
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
    return '앱에서 설정 변경이 필요합니다. ';
  }
  return '앱 권한 허가';
}
