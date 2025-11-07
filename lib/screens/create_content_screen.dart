import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../models/discovery.dart';
import '../models/social_post.dart';
import '../widgets/section_header.dart';

/// Screen for creating and sharing social media content
class CreateContentScreen extends StatefulWidget {
  final Discovery? discovery;

  const CreateContentScreen({super.key, this.discovery});

  @override
  State<CreateContentScreen> createState() => _CreateContentScreenState();
}

class _CreateContentScreenState extends State<CreateContentScreen> {
  final TextEditingController _captionController = TextEditingController();
  final List<SocialPlatform> _selectedPlatforms = [];
  final List<ConnectedSocialAccount> _connectedAccounts =
      getMockSocialAccounts();
  String? _videoPath;
  bool _includeGeotag = true;

  @override
  void initState() {
    super.initState();
    if (widget.discovery != null) {
      _captionController.text = SocialPost.generateCaption(
        discovery: widget.discovery!,
      );
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Contenido'),
        actions: [
          TextButton.icon(
            onPressed: _canPublish ? _publishContent : null,
            icon: const Icon(Icons.send),
            label: const Text('Publicar'),
            style: TextButton.styleFrom(
              foregroundColor:
                  _canPublish ? AppColors.primaryColor : Colors.grey,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video Preview / Camera
            _buildVideoSection(),
            const SizedBox(height: AppSpacing.l),

            // Discovery Info (if linked)
            if (widget.discovery != null) ...[
              _buildDiscoveryInfo(),
              const SizedBox(height: AppSpacing.l),
            ],

            // Caption Editor
            _buildCaptionSection(),
            const SizedBox(height: AppSpacing.l),

            // Platform Selector
            _buildPlatformSelector(),
            const SizedBox(height: AppSpacing.l),

            // Options
            _buildOptions(),
            const SizedBox(height: AppSpacing.l),

            // Preview
            _buildPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    return Card(
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        child:
            _videoPath == null
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam,
                      size: 80,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: AppSpacing.m),
                    Text(
                      'Graba tu Reel',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s),
                    Text(
                      'Captura tu experiencia en este lugar',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.l),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _openCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Grabar Video'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.l,
                              vertical: AppSpacing.m,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        OutlinedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galería'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.l,
                              vertical: AppSpacing.m,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
                : Stack(
                  children: [
                    // Video preview would go here
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_circle_outline,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: AppSpacing.s),
                          Text(
                            'Video cargado',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: AppSpacing.s,
                      right: AppSpacing.s,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _videoPath = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildDiscoveryInfo() {
    final discovery = widget.discovery!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.discoveryGradient),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Center(
                child: Text(
                  discovery.imageUrl,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    discovery.name,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          discovery.location,
                          style: AppTextStyles.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Chip(
              label: Text('+${discovery.xpReward} XP'),
              backgroundColor: AppColors.xpColor.withOpacity(0.1),
              labelStyle: TextStyle(
                color: AppColors.xpColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Descripción', icon: Icons.edit_note),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: _captionController,
          maxLines: 6,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: '¿Qué descubriste en este lugar?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        if (widget.discovery != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                SocialPost.generateHashtags(widget.discovery!)
                    .take(8)
                    .map(
                      (tag) => Chip(
                        label: Text('#$tag'),
                        labelStyle: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primaryColor,
                        ),
                        backgroundColor: AppColors.primaryColor.withOpacity(
                          0.1,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
          ),
      ],
    );
  }

  Widget _buildPlatformSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Publicar en', icon: Icons.share),
        const SizedBox(height: AppSpacing.s),
        ..._connectedAccounts.map((account) {
          final isConnected = account.isConnected;
          final isSelected = _selectedPlatforms.contains(account.platform);

          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.s),
            child: ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      isConnected
                          ? AppColors.primaryColor.withOpacity(0.1)
                          : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    account.platform.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              title: Text(account.platform.displayName),
              subtitle: Text(
                isConnected
                    ? '${account.username} • ${account.followersCount} seguidores'
                    : 'No conectado',
                style: TextStyle(
                  color: isConnected ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
              trailing:
                  isConnected
                      ? Checkbox(
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedPlatforms.add(account.platform);
                            } else {
                              _selectedPlatforms.remove(account.platform);
                            }
                          });
                        },
                        activeColor: AppColors.primaryColor,
                      )
                      : TextButton(
                        onPressed: () => _connectAccount(account.platform),
                        child: const Text('Conectar'),
                      ),
              enabled: isConnected,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Opciones', icon: Icons.tune),
        const SizedBox(height: AppSpacing.s),
        SwitchListTile(
          title: const Text('Incluir ubicación'),
          subtitle: const Text('Geoetiquetar automáticamente'),
          value: _includeGeotag,
          onChanged: (value) {
            setState(() {
              _includeGeotag = value;
            });
          },
          activeColor: AppColors.primaryColor,
          secondary: const Icon(Icons.location_on),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Vista Previa', icon: Icons.preview),
        const SizedBox(height: AppSpacing.s),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryColor,
                      child: const Text('👤', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('@tu_usuario', style: AppTextStyles.titleSmall),
                          if (_includeGeotag && widget.discovery != null)
                            Text(
                              widget.discovery!.location,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.m),
                Text(
                  _captionController.text.isEmpty
                      ? 'Tu descripción aparecerá aquí...'
                      : _captionController.text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color:
                        _captionController.text.isEmpty
                            ? Colors.grey[400]
                            : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool get _canPublish {
    return _videoPath != null &&
        _selectedPlatforms.isNotEmpty &&
        _captionController.text.isNotEmpty;
  }

  void _openCamera() {
    // TODO: Implement camera integration
    setState(() {
      _videoPath = 'mock_video_path.mp4';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📹 Función de cámara en desarrollo'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _pickFromGallery() {
    // TODO: Implement gallery picker
    setState(() {
      _videoPath = 'mock_video_from_gallery.mp4';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📁 Selector de galería en desarrollo'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _connectAccount(SocialPlatform platform) {
    // TODO: Implement OAuth integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conectando con ${platform.displayName}...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _publishContent() {
    if (!_canPublish) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¡Publicando!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.m),
                Text(
                  'Publicando en ${_selectedPlatforms.length} plataforma${_selectedPlatforms.length > 1 ? 's' : ''}...',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );

    // Simulate publishing
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Close dialog
        Navigator.pop(context); // Go back
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppSpacing.s),
                Expanded(
                  child: Text(
                    '¡Contenido publicado! +${widget.discovery?.xpReward ?? 100} XP',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }
}
