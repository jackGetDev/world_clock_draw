import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class WorldClockPage extends StatefulWidget {
  @override
  _WorldClockPageState createState() => _WorldClockPageState();
}

class WorldClock {
  final String location;
  final String timezone;
  final String flag;

  WorldClock({
    required this.location,
    required this.timezone,
    required this.flag,
  });
}

class _WorldClockPageState extends State<WorldClockPage> {
  List<WorldClock> filteredClocks = [];
  List<WorldClock> worldClocks = [
    WorldClock(location: 'Sydney', timezone: '+10', flag: '🇦🇺'),
    WorldClock(location: 'New York', timezone: '-4', flag: '🇺🇸'),
    WorldClock(location: 'London', timezone: '+1', flag: '🇬🇧'),
    WorldClock(location: 'Toronto', timezone: '-4', flag: '🇨🇦'),
    WorldClock(location: 'Paris', timezone: '+2', flag: '🇫🇷'),
    WorldClock(location: 'Berlin', timezone: '+2', flag: '🇩🇪'),
    WorldClock(location: 'Tokyo', timezone: '+9', flag: '🇯🇵'),
    WorldClock(location: 'Seoul', timezone: '+9', flag: '🇰🇷'),
    WorldClock(location: 'Singapore', timezone: '+8', flag: '🇸🇬'),
    WorldClock(location: 'Los Angeles', timezone: '-7', flag: '🇺🇸'),
    WorldClock(location: 'Rome', timezone: '+2', flag: '🇮🇹'),
    WorldClock(location: 'Dubai', timezone: '+4', flag: '🇦🇪'),
    WorldClock(location: 'Istanbul', timezone: '+3', flag: '🇹🇷'),
    WorldClock(location: 'Jakarta', timezone: '+7', flag: '🇮d'),
  ];

  @override
  void initState() {
    super.initState();
    filteredClocks = worldClocks;
    Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  void filterClocks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredClocks = worldClocks;
      } else {
        filteredClocks = worldClocks
            .where((clock) =>
                clock.location.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Clock'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: filterClocks,
              decoration: const InputDecoration(
                labelText: 'Search by City',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredClocks.length,
              itemBuilder: (context, index) {
                return WorldClockWidget(clock: filteredClocks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WorldClockWidget extends StatefulWidget {
  final WorldClock clock;

  WorldClockWidget({required this.clock});

  @override
  _WorldClockWidgetState createState() => _WorldClockWidgetState();
}

class _WorldClockWidgetState extends State<WorldClockWidget> {
  late Timer timer;
  late DateTime currentTime;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        currentTime = DateTime.now()
            .toUtc()
            .add(Duration(hours: int.parse(widget.clock.timezone)));
      });
    });
    currentTime = DateTime.now()
        .toUtc()
        .add(Duration(hours: int.parse(widget.clock.timezone)));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.clock.flag,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          widget.clock.location,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          '${currentTime.hour.toString().padLeft(2, '0')}:${currentTime.minute.toString().padLeft(2, '0')}:${currentTime.second.toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ClockWidget(currentTime: currentTime),
      ],
    );
  }
}

class ClockWidget extends StatelessWidget {
  final DateTime currentTime;

  ClockWidget({required this.currentTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      child: CustomPaint(
        painter: ClockPainter(currentTime: currentTime),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final DateTime currentTime;

  ClockPainter({required this.currentTime});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = min(centerX, centerY);

    final outlineBrush = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final centerPoint = Offset(centerX, centerY);

    // Outline circle
    canvas.drawCircle(centerPoint, radius - 2, outlineBrush);

    final now = currentTime;

    // Clock
    final hourHandX = centerX +
        radius * 0.4 * cos((now.hour * 30 + now.minute * 0.5 - 90) * pi / 180);
    final hourHandY = centerY +
        radius * 0.4 * sin((now.hour * 30 + now.minute * 0.5 - 90) * pi / 180);
    final hourHandEnd = Offset(hourHandX, hourHandY);
    final hourHandBrush = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawLine(centerPoint, hourHandEnd, hourHandBrush);

    // Minute
    final minuteHandX =
        centerX + radius * 0.6 * cos((now.minute * 6 - 90) * pi / 180);
    final minuteHandY =
        centerY + radius * 0.6 * sin((now.minute * 6 - 90) * pi / 180);
    final minuteHandEnd = Offset(minuteHandX, minuteHandY);
    final minuteHandBrush = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawLine(centerPoint, minuteHandEnd, minuteHandBrush);

  // Second
    final secondHandX =
        centerX + radius * 0.7 * cos((now.second * 6 - 90) * pi / 180);
    final secondHandY =
        centerY + radius * 0.7 * sin((now.second * 6 - 90) * pi / 180);
    final secondHandEnd = Offset(secondHandX, secondHandY);
    final secondHandBrush = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(centerPoint, secondHandEnd, secondHandBrush);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
