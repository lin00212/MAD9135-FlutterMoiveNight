import 'package:final_project/screens/welcome_screen.dart';
import 'package:final_project/utils/http_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:final_project/utils/app_state.dart';
import 'dart:math';

class MovieSelectionScreen extends StatefulWidget {
  const MovieSelectionScreen({super.key});
  @override
  State<MovieSelectionScreen> createState() => _MovieSelectionScreenState();
}

class _MovieSelectionScreenState extends State<MovieSelectionScreen> {
  List<Map<String, dynamic>> movies = [];
  int currentIndex = 0;
  int page = 1;
  bool isLoading = true;
  double _swipePosition = 0;

  @override
  void initState() {
    super.initState();
    getMovies(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: isLoading
                  ? _buildLoader()
                  : movies.isEmpty
                      ? _buildEmptyState()
                      : _buildMovieSwiper(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.teal.withOpacity(0.2),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.teal),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 20),
          const Text(
            'Movie Matcher',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade300),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading Movies...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_creation_outlined,
              size: 100, color: Colors.teal.shade300),
          const SizedBox(height: 20),
          const Text(
            'No Movies Available',
            style: TextStyle(color: Colors.white70, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieSwiper() {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _swipePosition += details.delta.dx;
        });
      },
      onHorizontalDragEnd: (details) {
        if (_swipePosition.abs() > 100) {
          handleVote(_swipePosition > 0);
        }
        setState(() {
          _swipePosition = 0;
        });
      },
      child: Stack(
        children: [
          _buildMovieCard(),
          _buildSwipeOverlay(),
        ],
      ),
    );
  }

  Widget _buildMovieCard() {
    return Transform.translate(
      offset: Offset(_swipePosition, 0),
      child: Transform.rotate(
        angle: _swipePosition / 1000,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              children: [
                Image.network(
                  'https://image.tmdb.org/t/p/w500${movies[currentIndex]['poster_path']}',
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),
                _buildMovieInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovieInfo() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movies[currentIndex]['title'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.star, color: Colors.teal.shade300),
                const SizedBox(width: 5),
                Text(
                  '${movies[currentIndex]['vote_average']}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeOverlay() {
    return Positioned.fill(
      child: Opacity(
        opacity: min(_swipePosition.abs() / 100, 1),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _swipePosition > 0
                    ? Colors.green.withOpacity(0.5)
                    : Colors.transparent,
                _swipePosition < 0
                    ? Colors.red.withOpacity(0.5)
                    : Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }

  Future<void> handleVote(bool isLike) async {
    try {
      final response = await HttpHelper.voteMovie(
        Provider.of<AppState>(context, listen: false).sessionId,
        movies[currentIndex]['id'].toString(),
        isLike,
      );

      if (response['data']['match'] == true) {
        _showMatchDialog(movies[currentIndex]);
      } else {
        setState(() {
          currentIndex++;
          if (currentIndex >= movies.length - 3) {
            page++;
            getMovies(context);
          }
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to vote: $e');
    }
  }

  void _showMatchDialog(Map<String, dynamic> movie) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.celebration, size: 50, color: Colors.amber.shade300),
              const SizedBox(height: 20),
              Text(
                "It's a Match!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                movie['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> getMovies(BuildContext context) async {
    try {
      final response = await HttpHelper.getPopularMovies(page);
      setState(() {
        if (page == 1) {
          movies = List<Map<String, dynamic>>.from(response['results']);
        } else {
          movies.addAll(List<Map<String, dynamic>>.from(response['results']));
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to load movies: $e');
    }
  }
}
