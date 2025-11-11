import 'package:flutter/material.dart';
import '../models/camera_settings.dart';
import '../services/camera_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class CameraSettingsScreen extends StatefulWidget {
  final CameraService cameraService;

  const CameraSettingsScreen({super.key, required this.cameraService});

  @override
  State<CameraSettingsScreen> createState() => _CameraSettingsScreenState();
}

class _CameraSettingsScreenState extends State<CameraSettingsScreen> {
  late CameraSettings _currentSettings;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.cameraService.settings;

    // Escuchar cambios en la configuración
    widget.cameraService.settingsStream.listen((settings) {
      if (mounted) {
        setState(() {
          _currentSettings = settings;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Configuración de Cámara',
          style: AppTextStyles.headlineSmall.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
              : ListView(
                padding: const EdgeInsets.all(AppSpacing.m),
                children: [
                  _buildFlashSettings(),
                  const SizedBox(height: AppSpacing.m),
                  _buildHDRSetting(),
                  const SizedBox(height: AppSpacing.m),
                  _buildQualitySettings(),
                  const SizedBox(height: AppSpacing.m),
                  _buildCameraSettings(),
                  const SizedBox(height: AppSpacing.m),
                  _buildZoomSettings(),
                  const SizedBox(height: AppSpacing.l),
                  _buildSaveButton(),
                ],
              ),
    );
  }

  Widget _buildFlashSettings() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.arOverlayBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Text(
              'Flash',
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
          ),
          ...CameraFlashMode.values.map(
            (mode) => RadioListTile<CameraFlashMode>(
              title: Text(
                _getFlashModeText(mode),
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              value: mode,
              groupValue: _currentSettings.flashMode,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentSettings = _currentSettings.copyWith(
                      flashMode: value,
                    );
                  });
                }
              },
              activeColor: AppColors.primaryColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHDRSetting() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.arOverlayBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: SwitchListTile(
        title: Text(
          'HDR',
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        subtitle: Text(
          'Mejora la calidad de imagen en condiciones de poca luz',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        value: _currentSettings.hdrEnabled,
        onChanged: (value) {
          setState(() {
            _currentSettings = _currentSettings.copyWith(hdrEnabled: value);
          });
        },
        activeColor: AppColors.primaryColor,
        contentPadding: const EdgeInsets.all(AppSpacing.m),
      ),
    );
  }

  Widget _buildQualitySettings() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.arOverlayBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Text(
              'Calidad de Video',
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
          ),
          ...CameraQuality.values.map(
            (quality) => RadioListTile<CameraQuality>(
              title: Text(
                _getQualityText(quality),
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
              ),
              value: quality,
              groupValue: _currentSettings.quality,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _currentSettings = _currentSettings.copyWith(
                      quality: value,
                    );
                  });
                }
              },
              activeColor: AppColors.primaryColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.m,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraSettings() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.arOverlayBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: SwitchListTile(
        title: Text(
          'Usar Cámara Frontal',
          style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
        ),
        subtitle: Text(
          'Cambiar entre cámara frontal y trasera',
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        value: _currentSettings.useFrontCamera,
        onChanged: (value) {
          setState(() {
            _currentSettings = _currentSettings.copyWith(useFrontCamera: value);
          });
        },
        activeColor: AppColors.primaryColor,
        contentPadding: const EdgeInsets.all(AppSpacing.m),
      ),
    );
  }

  Widget _buildZoomSettings() {
    // Límites de zoom
    const double minZoom = 1.0;
    const double maxZoom = 5.0;
    double currentZoom = _currentSettings.zoomLevel;

    // Asegurar que el zoom esté dentro de límites razonables
    if (currentZoom < minZoom) {
      currentZoom = minZoom;
    } else if (currentZoom > maxZoom) {
      currentZoom = maxZoom;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.arOverlayBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Text(
              'Zoom',
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
          ),
          Slider(
            value: currentZoom,
            min: minZoom,
            max: maxZoom,
            divisions: ((maxZoom - minZoom) * 10).round().clamp(1, 20),
            onChanged: (value) {
              setState(() {
                _currentSettings = _currentSettings.copyWith(zoomLevel: value);
              });
            },
            activeColor: AppColors.primaryColor,
            inactiveColor: Colors.white.withOpacity(0.3),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
            child: Text(
              '${currentZoom.toStringAsFixed(1)}x',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
        ),
        child: Text(
          'Guardar Configuración',
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.cameraService.updateSettings(
        flashMode: _currentSettings.flashMode,
        hdrEnabled: _currentSettings.hdrEnabled,
        quality: _currentSettings.quality,
        useFrontCamera: _currentSettings.useFrontCamera,
        zoomLevel: _currentSettings.zoomLevel,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración guardada exitosamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getFlashModeText(CameraFlashMode mode) {
    switch (mode) {
      case CameraFlashMode.auto:
        return 'Automático';
      case CameraFlashMode.always:
        return 'Siempre encendido';
      case CameraFlashMode.off:
        return 'Siempre apagado';
    }
  }

  String _getQualityText(CameraQuality quality) {
    switch (quality) {
      case CameraQuality.low:
        return 'Baja (ahorro de datos)';
      case CameraQuality.medium:
        return 'Media (balanceado)';
      case CameraQuality.high:
        return 'Alta (máxima calidad)';
      case CameraQuality.max:
        return 'Máxima (nativa del dispositivo)';
    }
  }
}
