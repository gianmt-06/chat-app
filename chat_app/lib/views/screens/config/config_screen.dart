import 'package:chat_app/views/widgets/utils/back_appbar_button.dart';
import 'package:chat_app/views/widgets/utils/title_paragraph.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  late bool fingerprintEnabled;

  void loadFingerPrintPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final fingerprintPreference = prefs.getBool('fingerprint_auth') ?? false;

    setState(() {
      fingerprintEnabled = fingerprintPreference;
    });
  }

  void changeFingerprintPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('fingerprint_auth', value);

    setState(() {
      fingerprintEnabled = value;
    });
  }

  @override
  void initState() {
    loadFingerPrintPreference();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Configuraciones",
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: BackAppbarButton(
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onTap: () {
                  setState(() {
                    fingerprintEnabled = !fingerprintEnabled;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TitleParagraph(
                        title: "Desbloqueo con huella",
                        paragraph:
                            "Requerir huella digital cada vez que se inicie la aplicación",
                      ),
                      SizedBox(width: 10),
                      Switch(
                        value: fingerprintEnabled,
                        activeColor: Color(0xFF2C82FF),
                        onChanged: (bool value) {
                          changeFingerprintPreference(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
