import 'package:chat_app/constants/color_constans.dart';
import 'package:chat_app/views/widgets/utils/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(right: 15, left: 15, bottom: 130),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Transform.scale(scale: 0.8, child: Image.asset('assets/images/cover_image.png')),
                    Text(
                      "Bienvenido a ChatApp",
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Comunícate con quien tú quieras, cuando tú quieras. El límite lo pones tú",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w200,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 70),
              Row(
                children: [
                  Expanded(
                    child: ButtonWidget(
                      buttonColor: const Color.fromARGB(255, 232, 244, 255),
                      textColor: ColorConstants.mainColor,
                      onPressed: () {
                        context.push('/login');
                      },
                      text: "Iniciar sesión",
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: ButtonWidget(
                      buttonColor: ColorConstants.mainColor,
                      textColor: ColorConstants.whiteColor,
                      onPressed: () {
                        context.push('/register');
                      },
                      text: "Crear una cuenta",
                    ),
                  ),
                ],
              ),
              // Column(
              //   children: [
              //     ElevatedButton(onPressed: () {}, child: Text("Ingresar")),
              //     ElevatedButton(
              //       onPressed: () {},
              //       child: Text("Crear una cuenta"),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
