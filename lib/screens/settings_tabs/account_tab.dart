import 'package:flutter/material.dart';
import 'package:sassy/widgets/message_display.dart';
import 'package:sassy/widgets/form_fields.dart';

class AccountTab extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final TextEditingController birthdateController;
  final TextEditingController emailController;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final Function() onSave;

  const AccountTab({
    Key? key,
    required this.nameController,
    required this.surnameController,
    required this.birthdateController,
    required this.emailController,
    required this.isLoading,
    required this.errorMessage,
    required this.successMessage,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Center(
          child: Stack(
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundColor: Color(0xFFF4A261),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        // Status messages
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
        
        FormTextField(
          label: "Meno", 
          placeholder: "Zadajte vaše meno", 
          controller: nameController
        ),
        const SizedBox(height: 10),
        FormTextField(
          label: "Priezvisko", 
          placeholder: "Zadajte vaše priezvisko", 
          controller: surnameController
        ),
        const SizedBox(height: 10),
        FormDateField(
          label: "Dátum narodenia", 
          placeholder: "DD.MM.RRRR", 
          controller: birthdateController
        ),
        const SizedBox(height: 10),
        FormTextField(
          label: "Email", 
          placeholder: "Zadajte váš email", 
          controller: emailController
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Vaše osobné údaje sú chránené a používané len na účely zlepšenia vašej skúsenosti s aplikáciou.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
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
          label: Text(isLoading ? "Aktualizácia..." : "Uložiť zmeny"),
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
              