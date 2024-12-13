import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:final_project/utils/app_state.dart';
import 'package:final_project/utils/http_helper.dart';
import 'package:final_project/utils/preference_helper.dart';
import 'package:final_project/screens/movie_selection_screen.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});
  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen>
    with SingleTickerProviderStateMixin {
  String code = '';
  final int codeLength = 4;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFF2C3E50),
            const Color(0xFF3498DB).withOpacity(0.8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            'Join Session',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              _buildCodeIcon(),
              const SizedBox(height: 30),
              _buildInstructions(),
              const SizedBox(height: 40),
              _buildCodeInput(),
              const SizedBox(height: 50),
              _buildJoinButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeIcon() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3498DB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.vpn_key_rounded,
        size: 60,
        color: Color(0xFF3498DB),
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      children: const [
        Text(
          'Enter Code',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Please enter the 4-digit code\nfrom your friend',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 20,
          color: Color(0xFF2C3E50),
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: codeLength,
        onChanged: (value) {
          setState(() => code = value);
          if (value.length == codeLength) {
            _animationController
                .forward()
                .then((_) => _animationController.reverse());
          }
        },
        decoration: InputDecoration(
          counterText: "",
          hintText: "0000",
          fillColor: const Color(0xFFF5F6FA),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildJoinButton() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3498DB).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: code.length == codeLength
                  ? () => _joinSession(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Join Now",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _joinSession(context) async {
    String? deviceId = Provider.of<AppState>(context, listen: false).deviceId;
    try {
      final response = await HttpHelper.joinSession(code, deviceId);
      String sessionId = response['data']['session_id'];
      Provider.of<AppState>(context, listen: false).setSessionId(sessionId);
      await PreferenceHelper.setSessionId(sessionId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MovieSelectionScreen(),
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Cannot join session',
              style: TextStyle(
                color: Colors.indigo.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              '$e',
              style: TextStyle(
                color: Colors.indigo.shade900,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.indigo.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}
