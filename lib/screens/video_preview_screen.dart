import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class VideoPreviewScreen extends StatefulWidget {
  final XFile videoFile;
  final VoidCallback? onConfirm;
  final VoidCallback? onDiscard;
  final VoidCallback? onRetake;

  const VideoPreviewScreen({
    super.key,
    required this.videoFile,
    this.onConfirm,
    this.onDiscard,
    this.onRetake,
  });

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.file(File(widget.videoFile.path));
      
      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        // Reproducir automáticamente
        await _controller!.play();
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar video: $e')),
        );
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_controller == null || !_isInitialized) return;
    
    if (_isPlaying) {
      await _controller!.pause();
    } else {
      await _controller!.play();
    }
    
    if (mounted) {
      setState(() {
        _isPlaying = _controller!.value.isPlaying;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      widget.onDiscard?.call();
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    'Preview del Video',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance del layout
                ],
              ),
            ),
            
            // Video Player
            Expanded(
              child: Center(
                child: _isInitialized && _controller != null
                    ? GestureDetector(
                        onTap: _togglePlayPause,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: VideoPlayer(_controller!),
                            ),
                            // Play/Pause Overlay
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 64,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
              ),
            ),
            
            // Controls
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                children: [
                  // Play/Pause Button
                  if (_isInitialized && _controller != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.m),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                        ],
                      ),
                    ),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Retake Button
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            widget.onRetake?.call();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.m,
                            ),
                            side: const BorderSide(color: Colors.white),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMedium,
                              ),
                            ),
                          ),
                          child: Text(
                            'Volver a grabar',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      // Confirm Button
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            widget.onConfirm?.call();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.m,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMedium,
                              ),
                            ),
                          ),
                          child: Text(
                            'Confirmar',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

