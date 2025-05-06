import 'dart:io';

import 'package:chat_app/constants/color_constans.dart';
import 'package:chat_app/entities/user.dart';
import 'package:chat_app/models/auth_model.dart';
import 'package:chat_app/utils/image_utils.dart';
import 'package:chat_app/views/widgets/utils/button_widget.dart';
import 'package:chat_app/views/widgets/utils/dropdown_widget.dart';
import 'package:chat_app/views/widgets/utils/form_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

final _formKey = GlobalKey<FormState>();

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String selectedValue = 'auxiliar';
  final List<String> options = [
    'auxiliar',
    'técnico redes',
    'servicios generales',
    'operador logístico',
    'contador',
    'subgerente',
    'desarrollador',
    'administrador',
  ];

  final ImagePicker _picker = ImagePicker();
  File? _profilePicture;

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile == null) {
      debugPrint("No se seleccionó ninguna imagen.");
    } else {
      final File image = await compressImageFile(File(pickedFile.path));
      setState(() {
        _profilePicture = image;
      });
    }
  }

  void _sendForm() async {
    final authModel = AuthModel();
    final response = await authModel.registerUser(
      User(
        email: emailController.text,
        password: passwordController.text,
        name: nameController.text,
        lastName: lastNameController.text,
        phoneNumber: phoneNumberController.text,
        rol: selectedValue,
      ),
      _profilePicture,
    );

    if (!mounted) return;
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Registro exitoso. Ahora puedes iniciar sesión',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al registrar usuario',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Registrate",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      "Ingresa la información requerida para completar tu registro.",
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 15,
                        fontWeight: FontWeight.w200,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _pickImage();
                      },
                      child: CircleAvatar(
                        radius: 90,
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            _profilePicture != null
                                ? FileImage(_profilePicture!)
                                : AssetImage('assets/images/no_image.png'),
                      ),
                    ),
                    SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          FormTextField(
                            controller: nameController,
                            placeholder: "Ingresa tu nombre",
                            label: "Nombre",
                          ),
                          FormTextField(
                            controller: lastNameController,
                            placeholder: "Apellidos",
                            label: "Apellidos",
                          ),
                          FormTextField(
                            controller: emailController,
                            placeholder: "Ingresa tu email",
                            label: "Email",
                          ),
                          FormTextField(
                            controller: passwordController,
                            placeholder: "Ingresa una nueva contraseña",
                            label: "Contraseña",
                            isPassword: true,
                          ),
                          FormTextField(
                            controller: phoneNumberController,
                            placeholder: "Ingresa tu número de teléfono",
                            label: "Celular",
                          ),
                          FormDropdownField<String>(
                            value: selectedValue,
                            items:
                                options
                                    .map(
                                      (option) => DropdownMenuItem(
                                        value: option,
                                        child: Text(option),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (val) => setState(() => selectedValue = val!),
                            label: 'Cargo',
                            hint: 'Selecciona un cargo',
                            validator:
                                (val) => val == null ? 'Requerido' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Expanded(
              child: ButtonWidget(
                buttonColor: ColorConstants.mainColor,
                textColor: ColorConstants.whiteColor,
                onPressed: () {
                  bool isValid = _formKey.currentState!.validate();

                  if (isValid) {
                    _sendForm();
                  } else {
                    debugPrint("Formulario invalido");
                  }
                },
                text: "Registrar",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
