class DroneData {
  final double battery;
  final double altitude;
  final double speed;
  final double heading;
  final double latitude;
  final double longitude;
  final int gpsSatellites;
  final bool connected;
  final String flightMode;

  const DroneData({
    required this.battery,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.latitude,
    required this.longitude,
    required this.gpsSatellites,
    required this.connected,
    required this.flightMode,
  });
}