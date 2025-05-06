import 'package:chat_app/constants/color_constans.dart';
import 'package:chat_app/models/auth_model.dart';
import 'package:chat_app/views/widgets/utils/button_widget.dart';
import 'package:chat_app/views/widgets/utils/form_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

final _loginFormKey = GlobalKey<FormState>();

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> _login() async {
    final authModel = AuthModel();
    final response = await authModel.login(
      emailController.text,
      passwordController.text,
    );

    if (!mounted) return false;
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login exitoso', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      context.go('/home')  ;
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Credenciales incorrectas',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Ingresar",
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Form(
                key: _loginFormKey,
                child: Column(
                  children: [
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
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ButtonWidget(
                              buttonColor: ColorConstants.mainColor,
                              textColor: ColorConstants.whiteColor,
                              onPressed: () async {
                                bool isValid =
                                    _loginFormKey.currentState!.validate();

                                if (isValid) {
                                  debugPrint("Formulario valido");
                                  await _login();
                                
                                } else {
                                  debugPrint("Formulario invalido");
                                }
                              },
                              text: "Ingresar",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
