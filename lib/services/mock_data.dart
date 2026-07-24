import '../models/drone_data.dart';

class MockData {
  static const DroneData drone = DroneData(
    battery: 92,
    altitude: 14.5,
    speed: 3.2,
    heading: 270,
    latitude: 13.35241,
    longitude: 74.79298,
    gpsSatellites: 15,
    connected: true,
    flightMode: "AUTO",
  );
}