import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/prediction_service.dart';

class DropZone extends StatefulWidget {
  final Function(Map<String, dynamic>) onPredictionResults;
  final double maxHeight;

  const DropZone({
    super.key,
    required this.onPredictionResults,
    required this.maxHeight,
  });

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool _dragging = false;
  String? _imagePath;
  bool _isLoading = false;
  final PredictionService _predictionService = PredictionService();

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _imagePath = result.files.first.path;
      });
    }
  }

  void _handleDrop(DropDoneDetails details) {
    if (details.files.isNotEmpty) {
      final file = details.files.first;
      if (file.path.toLowerCase().endsWith('.jpg') ||
          file.path.toLowerCase().endsWith('.jpeg') ||
          file.path.toLowerCase().endsWith('.png')) {
        setState(() {
          _imagePath = file.path;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please drop an image file (jpg, jpeg, or png)'),
            ),
          );
        }
      }
    }
  }

  Future<void> _predict() async {
    if (_imagePath == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results =
          await _predictionService.getPredictions(File(_imagePath!));
      widget.onPredictionResults(results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildDropTarget() {
    final screenSize = MediaQuery.of(context).size;
    final dropZoneSize = Size(
      screenSize.width * 0.4,
      widget.maxHeight * 0.7,
    );

    return DropTarget(
      onDragDone: _handleDrop,
      onDragEntered: (details) => setState(() => _dragging = true),
      onDragExited: (details) => setState(() => _dragging = false),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: widget.maxHeight * 0.05,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: dropZoneSize.width,
                  height: dropZoneSize.height,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _dragging ? Colors.blue : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    color: _dragging
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 80,
                        color: _dragging ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Drop image here',
                        style: TextStyle(
                          color: _dragging ? Colors.blue : Colors.grey,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Choose File'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final screenSize = MediaQuery.of(context).size;
    final imageSize = Size(
      screenSize.width * 0.4,
      screenSize.height * 0.4,
    );

    return DropTarget(
      onDragDone: _handleDrop,
      onDragEntered: (details) => setState(() => _dragging = true),
      onDragExited: (details) => setState(() => _dragging = false),
      child: SizedBox(
        height: widget.maxHeight,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            0,
            screenSize.height * 0.029,
            0,
            screenSize.height * 0.0069,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Container(
                    width: imageSize.width,
                    height: imageSize.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: _dragging
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        File(_imagePath!),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Choose Another File'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.02,
                        vertical: screenSize.height * 0.015,
                      ),
                      textStyle: TextStyle(
                        fontSize: screenSize.width * 0.012,
                      ),
                    ),
                  ),
                  SizedBox(width: screenSize.width * 0.02),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _predict,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.02,
                        vertical: screenSize.height * 0.015,
                      ),
                      textStyle: TextStyle(
                        fontSize: screenSize.width * 0.012,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Predict'),
                  ),
                ],
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Check if container is too small for meaningful display
    if (widget.maxHeight < 300 || screenSize.width < 400) {
      return const SizedBox.shrink();
    }

    return _imagePath == null ? _buildDropTarget() : _buildImagePreview();
  }
}
