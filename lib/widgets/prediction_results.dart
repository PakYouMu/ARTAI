import 'package:flutter/material.dart';

class PredictionResults extends StatelessWidget {
  final Map<String, dynamic>? results;

  const PredictionResults({super.key, this.results});

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  List<MapEntry<String, dynamic>> _getSortedEntries() {
    if (results == null) return [];
    var entries = results!.entries.toList();
    entries.sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  List<MapEntry<String, dynamic>> _getSortedProbabilities(
      Map<String, dynamic> probabilities) {
    final desiredOrder = ['Acrylic', 'Oil', 'Pastel', 'Water Color'];
    return probabilities.entries.toList()
      ..sort((a, b) {
        final indexA = desiredOrder.indexOf(a.key);
        final indexB = desiredOrder.indexOf(b.key);
        if (indexA != -1 && indexB != -1) return indexA.compareTo(indexB);
        if (indexA != -1) return -1;
        if (indexB != -1) return 1;
        return a.key.compareTo(b.key);
      });
  }

  @override
  Widget build(BuildContext context) {
    if (results == null) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;
    final sortedEntries = _getSortedEntries();

    // Calculate the number of cards per row based on screen width
    int crossAxisCount = (screenSize.width / 400).floor();
    crossAxisCount =
        crossAxisCount.clamp(1, 3); // Limit between 1 and 3 cards per row

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.21,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: sortedEntries.length,
          itemBuilder: (context, index) {
            final entry = sortedEntries[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Model Name
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.key.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Prediction and Confidence
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value['prediction'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Confidence: ${(_parseDouble(entry.value['confidence_score']) * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Probabilities
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: _getSortedProbabilities(
                                entry.value['probabilities'])
                            .map<Widget>((prob) => Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            prob.key,
                                            style:
                                                const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '${(_parseDouble(prob.value) * 100).toStringAsFixed(1)}%',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: _parseDouble(prob.value),
                                      backgroundColor: const Color(0xFF6366F1)
                                          .withOpacity(0.1),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Color(0xFF6366F1)),
                                      minHeight: 4,
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
