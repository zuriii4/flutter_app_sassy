import 'package:flutter/material.dart';
import 'package:sassy/widgets/message_display.dart';
import 'package:sassy/widgets/form_fields.dart';

class SpecializationTab extends StatelessWidget {
  final TextEditingController specializationController;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final Function() onSave;

  const SpecializationTab({
    Key? key,
    required this.specializationController,
    required this.isLoading,
    required this.errorMessage,
    required this.successMessage,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (errorMessage != null)
          MessageDisplay(
            message: errorMessage!,
            type: MessageType.error,
          ),
          
        if (successMessage != null)
          MessageDisplay(
            message: successMessage!,
            type: MessageType.success,
          ),
        
        const Text(
          "Vaša špecializácia",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        FormTextField(
          label: "Špecializácia", 
          placeholder: "Zadajte vašu špecializáciu", 
          controller: specializationController
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: isLoading ? null : onSave,
          icon: isLoading 
              ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2.0),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : const Icon(Icons.save),
          label: Text(isLoading ? "Aktualizácia..." : "Uložiť špecializáciu"),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF4A261),
            disabledBackgroundColor: const Color(0xFFF4A261).withOpacity(0.7),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}