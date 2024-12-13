import 'package:final_project/screens/movie_selection_screen.dart';
import 'package:final_project/utils/http_helper.dart';
import 'package:final_project/utils/preference_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/utils/app_state.dart';

class ShareCodeScreen extends StatefulWidget {
  const ShareCodeScreen({super.key});
  @override
  State<ShareCodeScreen> createState() => _ShareCodeScreenState();
}

class _ShareCodeScreenState extends State<ShareCodeScreen>
    with SingleTickerProviderStateMixin {
  String code = 'Unset';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _startSession(context);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: SafeArea(
        child: Stack(
          children: [
            _buildBackground(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        image: DecorationImage(
          image: const AssetImage(
              'assets/pattern.png'), // Add a subtle pattern image
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.1),
            BlendMode.dstATop,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildAppBar(),
        Expanded(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCodeDisplay(),
                  const SizedBox(height: 40),
                  _buildInstructions(),
                  const SizedBox(height: 60),
                  _buildStartButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Your Session',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeDisplay() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF34495E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.qr_code,
            size: 80,
            color: Color(0xFF1ABC9C),
          ),
          const SizedBox(height: 24),
          Text(
            code,
            style: const TextStyle(
              color: Color(0xFF1ABC9C),
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF34495E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          Text(
            '🎬 How to use',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Share this code with your movie buddy to sync your preferences and find the perfect movie match!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1ABC9C),
            Color(0xFF16A085),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1ABC9C).withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MovieSelectionScreen(),
              ),
            );
          },
          child: const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Start Matching',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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

  void _startSession(context) async {
    String? deviceId = Provider.of<AppState>(context, listen: false).deviceId;
    final response = await HttpHelper.startSession(deviceId);
    setState(() {
      code = response['data']['code'];
    });
    Provider.of<AppState>(context, listen: false)
        .setSessionId(response['data']['session_id']);
    await PreferenceHelper.setSessionId(response['data']['session_id']);
  }
}
