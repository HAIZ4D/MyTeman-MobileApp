import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/tts_service.dart';
import '../utils/haptic_feedback.dart';

/// Document upload widget with camera guidance and voice support
class DocumentUploadWidget extends StatefulWidget {
  final String fieldName;
  final String language;
  final Function(String?) onFileSelected;

  const DocumentUploadWidget({
    super.key,
    required this.fieldName,
    required this.language,
    required this.onFileSelected,
  });

  @override
  State<DocumentUploadWidget> createState() => _DocumentUploadWidgetState();
}

class _DocumentUploadWidgetState extends State<DocumentUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  final TtsService _tts = TtsService();
  String? _selectedFilePath;
  bool _isUploading = false;

  Future<void> _takePicture() async {
    try {
      await HapticHelper.selection();

      // Voice guidance for taking picture
      final guidance = widget.language == 'ms'
          ? 'Sila ambil gambar dokumen dengan jelas. Pastikan dokumen berada dalam bingkai dan tidak kabur.'
          : 'Please take a clear picture of the document. Make sure the document is within the frame and not blurry.';

      await _tts.speak(guidance, language: widget.language);
      await Future.delayed(const Duration(milliseconds: 500));

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        setState(() {
          _selectedFilePath = photo.path;
          _isUploading = true;
        });

        await HapticHelper.success();

        // Simulate upload
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _isUploading = false;
        });

        widget.onFileSelected(photo.path);

        if (mounted) {
          final successMsg = widget.language == 'ms'
              ? 'Gambar berjaya dimuat naik'
              : 'Image uploaded successfully';
          await _tts.speak(successMsg, language: widget.language);
        }
      }
    } catch (e) {
      await HapticHelper.error();
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.language == 'ms'
                ? 'Ralat mengambil gambar: $e'
                : 'Error taking picture: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      await HapticHelper.selection();

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedFilePath = image.path;
          _isUploading = true;
        });

        await HapticHelper.success();

        // Simulate upload
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _isUploading = false;
        });

        widget.onFileSelected(image.path);

        if (mounted) {
          final successMsg = widget.language == 'ms'
              ? 'Fail berjaya dimuat naik'
              : 'File uploaded successfully';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMsg),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      await HapticHelper.error();
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.language == 'ms'
                ? 'Ralat memilih fail: $e'
                : 'Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFilePath = null;
    });
    widget.onFileSelected(null);
    HapticHelper.selection();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedFilePath != null) {
      return _buildSelectedFileView();
    } else {
      return _buildUploadOptions();
    }
  }

  Widget _buildUploadOptions() {
    return Column(
      children: [
        // Camera option
        Card(
          elevation: 2,
          child: InkWell(
            onTap: _isUploading ? null : _takePicture,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 32,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.language == 'ms' ? 'Ambil Gambar' : 'Take Photo',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.language == 'ms'
                              ? 'Gunakan kamera untuk mengambil gambar dokumen'
                              : 'Use camera to capture document',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Gallery option
        Card(
          elevation: 2,
          child: InkWell(
            onTap: _isUploading ? null : _pickFromGallery,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      size: 32,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.language == 'ms' ? 'Pilih dari Galeri' : 'Choose from Gallery',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.language == 'ms'
                              ? 'Pilih fail dari galeri peranti anda'
                              : 'Select file from device gallery',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 20),
                ],
              ),
            ),
          ),
        ),

        if (_isUploading) ...[
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          Text(
            widget.language == 'ms' ? 'Memuat naik...' : 'Uploading...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedFileView() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Preview image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_selectedFilePath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // File info
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.language == 'ms'
                        ? 'Dokumen berjaya dimuat naik'
                        : 'Document uploaded successfully',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _removeFile,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(widget.language == 'ms' ? 'Buang' : 'Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.refresh),
                    label: Text(widget.language == 'ms' ? 'Ambil Semula' : 'Retake'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
