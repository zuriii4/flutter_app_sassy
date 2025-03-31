import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:sassy/services/api_service.dart';
import 'package:file_picker/file_picker.dart'; 

class FormTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int? maxLength;
  final Function(String)? onChanged; // Pridaný parameter onChanged

  const FormTextField({
    Key? key,
    required this.label,
    required this.placeholder,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.onChanged, // Pridaný parameter do konštruktora
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          onChanged: onChanged, // Použitie onChanged parametra
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class FormPasswordField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final bool showPassword;
  final Function()? onToggleVisibility;

  const FormPasswordField({
    Key? key,
    required this.label,
    required this.placeholder,
    this.controller,
    required this.showPassword,
    this.onToggleVisibility,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: !showPassword,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            suffixIcon: IconButton(
              icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggleVisibility,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class FormDateField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;

  const FormDateField({
    Key? key,
    required this.label,
    required this.placeholder,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 10,
          decoration: InputDecoration(
            hintText: placeholder,
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF4F4F4),
            suffixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
            String formatted = '';
            for (int i = 0; i < clean.length && i < 8; i++) {
              formatted += clean[i];
              if ((i == 1 || i == 3) && i != clean.length - 1) {
                formatted += '/';
              }
            }
            controller?.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          },
        ),
      ],
    );
  }
}

class FormImagePicker extends StatefulWidget {
  final String label;
  final Function(String) onImagePathSelected; // Callback with the server path
  final String? initialImagePath; // Initial image path from server if editing
  
  const FormImagePicker({
    Key? key,
    required this.label,
    required this.onImagePathSelected,
    this.initialImagePath,
  }) : super(key: key);

  @override
  State<FormImagePicker> createState() => _FormImagePickerState();
}

class _FormImagePickerState extends State<FormImagePicker> {
  final ApiService _apiService = ApiService();
  File? _selectedImage;
  String? _serverImagePath;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _serverImagePath = widget.initialImagePath;
  }
  
  // Funkcia na výber obrázka zo súborov
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        _processSelectedImage(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba pri výbere súboru: $e')),
        );
      }
    }
  }
  
  // Spracovanie vybraného obrázka
  Future<void> _processSelectedImage(File image) async {
    setState(() {
      _selectedImage = image;
      _isLoading = true;
    });
    
    try {
      // Nahranie obrázka na server a získanie cesty
      final imagePath = await _apiService.uploadImage(image);
      
      if (imagePath != null) {
        setState(() {
          _serverImagePath = imagePath;
          _isLoading = false;
        });
        
        // Zavoláme callback s cestou k obrázku
        widget.onImagePathSelected(imagePath);
      } else {
        // Chyba pri nahrávaní
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nepodarilo sa nahrať obrázok')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        // Zobrazenie vybraného obrázka alebo prázdneho kontajnera
        GestureDetector(
          onTap: _isLoading ? null : _pickImage,
          child: Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildImagePreview(),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Tlačidlo pre výber obrázka
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _pickImage,
          icon: const Icon(Icons.file_upload),
          label: Text(_serverImagePath == null ? 'Vybrať súbor' : 'Zmeniť súbor'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF67E4A),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  // Metóda na zobrazenie náhľadu obrázka
  Widget _buildImagePreview() {
    // Ak máme lokálne vybraný obrázok, zobrazíme ho
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    
    // Ak máme cestu k obrázku na serveri, zobrazíme ho
    if (_serverImagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          _apiService.getImageUrl(_serverImagePath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Nepodarilo sa načítať obrázok',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    
    // Prázdny stav
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.upload_file, size: 50, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'Kliknutím vyberte súbor',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}