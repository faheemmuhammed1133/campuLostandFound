import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/item_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ReportItemScreen extends StatefulWidget {
  final String currentUser;

  const ReportItemScreen({super.key, required this.currentUser});

  @override
  State<ReportItemScreen> createState() => _ReportItemScreenState();
}

class _ReportItemScreenState extends State<ReportItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  Uint8List? _imageBytes;
  ItemType _selectedType = ItemType.lost;
  bool _isSubmitting = false;
  bool _isFetchingLocation = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      String? imageBase64;
      if (_imageBytes != null) {
        imageBase64 = base64Encode(_imageBytes!);
      }
      await ApiService.createItem(
        title: _nameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        imageBase64: imageBase64,
        type: _selectedType == ItemType.lost ? 'lost' : 'found',
        postedBy: widget.currentUser,
      );
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _fillCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final location = await ApiService.fetchCurrentApproxLocation();
      if (!mounted) return;
      setState(() {
        _locationController.text = location;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location fetched successfully.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLost = _selectedType == ItemType.lost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type selector
              const Text(
                'What happened?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedType = ItemType.lost),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color:
                              isLost ? AppTheme.lostLight : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isLost ? AppTheme.lost : AppTheme.border,
                            width: isLost ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.search_rounded,
                                color: isLost
                                    ? AppTheme.lost
                                    : AppTheme.textMuted,
                                size: 28),
                            const SizedBox(height: 6),
                            Text(
                              'I Lost Something',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isLost
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isLost
                                    ? AppTheme.lost
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _selectedType = ItemType.found),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: !isLost
                              ? AppTheme.foundLight
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                !isLost ? AppTheme.found : AppTheme.border,
                            width: !isLost ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                color: !isLost
                                    ? AppTheme.found
                                    : AppTheme.textMuted,
                                size: 28),
                            const SizedBox(height: 6),
                            Text(
                              'I Found Something',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: !isLost
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: !isLost
                                    ? AppTheme.found
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Item name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  prefixIcon: Icon(Icons.label_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  suffixIcon: _isFetchingLocation
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.my_location_rounded,
                              color: AppTheme.primary),
                          tooltip: 'Use Current Location',
                          onPressed: _fillCurrentLocation,
                        ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Image section
              if (_imageBytes != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      _imageBytes!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: Icon(
                  _imageBytes != null
                      ? Icons.swap_horiz_rounded
                      : Icons.add_photo_alternate_outlined,
                ),
                label: Text(_imageBytes != null ? 'Change Image' : 'Add Image'),
              ),
              const SizedBox(height: 28),

              // Submit
              _isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Submit Report'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
