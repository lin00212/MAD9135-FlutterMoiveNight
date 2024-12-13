import 'dart:io';
import 'dart:math';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:final_project/screens/enter_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:final_project/screens/share_code_screen.dart';
import 'package:provider/provider.dart';
import 'package:final_project/utils/app_state.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Color> _randomColors = [
    Colors.deepOrange,
    Colors.teal,
    Colors.purple,
    Colors.amber,
    Colors.pink,
  ];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeDeviceId(context);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRandomColor() {
    return _randomColors[_random.nextInt(_randomColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * pi,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: SweepGradient(
                      colors: [
                        _getRandomColor().withOpacity(0.5),
                        _getRandomColor().withOpacity(0.5),
                        _getRandomColor().withOpacity(0.5),
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
          // Content
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    '🎬 Movie Night',
                    style: TextStyle(
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  background: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent
                        ],
                      ).createShader(rect);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Image.network(
                      'https://picsum.photos/800/400',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildHexagonButton(
                        "Start New Adventure",
                        Icons.movie_creation,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ShareCodeScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildCircularButton(
                        "Join Others",
                        Icons.group,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EnterCodeScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHexagonButton(
      String text, IconData icon, VoidCallback? onPressed) {
    return ClipPath(
      clipper: HexagonClipper(),
      child: Material(
        color: _getRandomColor(),
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaveButton(String text, IconData icon, VoidCallback? onPressed) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            _getRandomColor(),
            _getRandomColor(),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton(
      String text, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              _getRandomColor(),
              _getRandomColor().withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 40),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Existing methods remain unchanged
  void _initializeDeviceId(context) async {
    String deviceId = await _fetchDeviceId();
    Provider.of<AppState>(context, listen: false).setDeviceId(deviceId);
  }

  Future<String> _fetchDeviceId() async {
    String deviceId;
    try {
      if (Platform.isAndroid) {
        const androidIdPlugin = AndroidId();
        deviceId = await androidIdPlugin.getId() ?? "Unknown Android ID";
      } else if (Platform.isIOS) {
        final deviceInfoPlugin = DeviceInfoPlugin();
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "Unknown iOS UUID";
      } else {
        deviceId = 'Unsupported platform';
      }
    } catch (e) {
      deviceId = "Error: $e";
    }
    return deviceId;
  }
}

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final height = size.height;
    final width = size.width;

    path.moveTo(width * 0.25, 0);
    path.lineTo(width * 0.75, 0);
    path.lineTo(width, height * 0.5);
    path.lineTo(width * 0.75, height);
    path.lineTo(width * 0.25, height);
    path.lineTo(0, height * 0.5);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
