class MockRequest {
  final String title;
  final String subtitle;
  final String name;
  final String location;
  final String destination;
  final String time;
  final String distance;
  final String imageUrl;

  MockRequest({
    required this.title,
    required this.subtitle,
    required this.name,
    required this.location,
    required this.destination,
    required this.time,
    required this.distance,
    required this.imageUrl,
  });
}

class MockData {
  static final mainDriverRequest = MockRequest(
    title: 'New Pick Me Alert!',
    subtitle: 'Support Driver needs a ride',
    name: 'Alex (Support)',
    location: '456 Uptown Blvd',
    destination: '789 Suburbia Lane',
    time: '25 mins',
    distance: '8.5 miles',
    imageUrl: 'https://i.pravatar.cc/150?img=11',
  );

  static final supportDriverRequest = MockRequest(
    title: 'New Pickup Alert!',
    subtitle: 'Customer needs a ride',
    name: 'John Doe (Customer)',
    location: '123 Downtown Ave',
    destination: '456 Business Bay',
    time: '12 mins',
    distance: '4.5 miles',
    imageUrl: 'https://i.pravatar.cc/150?img=33',
  );
}
