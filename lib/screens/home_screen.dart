import 'package:flutter/material.dart';
import '../widgets/drop_zone.dart';
import '../widgets/prediction_results.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _predictionResults;
  static const double minWidth = 800.0;
  static const double minHeight = 600.0;

  void _updatePredictionResults(Map<String, dynamic> results) {
    setState(() {
      _predictionResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final containerHeight = screenSize.height * 0.4;
    final topSectionHeight = screenSize.height - containerHeight - 32;
    final isScreenTooSmall =
        screenSize.width < minWidth || screenSize.height < minHeight;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topSectionHeight,
            child: DropZone(
              onPredictionResults: _updatePredictionResults,
              maxHeight: topSectionHeight,
            ),
          ),
          if (isScreenTooSmall)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Please resize the window to at least 800x600 pixels to use this application.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (!isScreenTooSmall)
            Positioned(
              bottom: 15.69,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: containerHeight * 1.1,
                margin: EdgeInsets.symmetric(
                  horizontal: screenSize.width * 0.05,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(screenSize.width * 0.02),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Prediction Results',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenSize.width * 0.02,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (_predictionResults != null)
                          PredictionResults(results: _predictionResults!),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
