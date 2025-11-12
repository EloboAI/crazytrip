import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

/// BottomSheet de pantalla completa para sugerir corrección de identificación
/// Más amigable con el teclado que un AlertDialog
class CorrectionSuggestionDialog extends StatefulWidget {
  final String originalName;
  final String originalDescription;

  const CorrectionSuggestionDialog({
    super.key,
    required this.originalName,
    required this.originalDescription,
  });

  @override
  State<CorrectionSuggestionDialog> createState() =>
      _CorrectionSuggestionDialogState();
}

class _CorrectionSuggestionDialogState
    extends State<CorrectionSuggestionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Sugerir corrección'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            child:
                _isSubmitting
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('ENVIAR'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.l),
          children: [
            // Mensaje de ayuda
            Card(
              color: Colors.blue.withOpacity(0.1),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tu sugerencia nos ayuda a mejorar la precisión del reconocimiento. Ingresa el nombre y descripción correctos.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l),

            // Identificación actual
            Text(
              'Identificación actual',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.originalName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.originalDescription,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),

            // Separador
            const Divider(),
            const SizedBox(height: AppSpacing.l),

            // Corrección sugerida
            Text(
              'Tu corrección',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // Campo de nombre correcto
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre correcto *',
                hintText: 'Ej: Torre Eiffel',
                prefixIcon: const Icon(Icons.label),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                if (value.trim().length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
              maxLength: 100,
            ),
            const SizedBox(height: AppSpacing.l),

            // Campo de descripción correcta
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción correcta *',
                hintText: 'Ej: Monumento icónico de París, Francia',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa una descripción';
                }
                if (value.trim().length < 10) {
                  return 'La descripción debe tener al menos 10 caracteres';
                }
                return null;
              },
              maxLines: 6,
              minLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.l),

            // Nota de privacidad
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.privacy_tip_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tu sugerencia se guardará de forma segura y podría usarse para mejorar nuestros modelos de AI.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simular envío (aquí se integraría con FeedbackService)
      await Future.delayed(const Duration(seconds: 1));

      final suggestion = {
        'original_name': widget.originalName,
        'original_description': widget.originalDescription,
        'corrected_name': _nameController.text.trim(),
        'corrected_description': _descriptionController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      // TODO: Guardar en FeedbackService
      debugPrint('📝 Sugerencia de corrección: $suggestion');

      if (!mounted) return;

      // Cerrar diálogo y retornar sugerencia
      Navigator.of(context).pop(suggestion);

      // Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('¡Gracias! Tu sugerencia ha sido guardada.'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar sugerencia: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
