import 'package:flutter/material.dart';
// import 'package:homiletics/classes/language.dart';
import 'package:homiletics/classes/preferences.dart';
import 'package:homiletics/classes/translation.dart';

class PreferencesModal extends StatefulWidget {
  const PreferencesModal({Key? key}) : super(key: key);
  @override
  _PreferencesModalState createState() => _PreferencesModalState();
}

class _PreferencesModalState extends State<PreferencesModal> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: ShapeBorder.lerp(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        0.5,
      ),
      child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            const Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(width: 12),
              Icon(Icons.settings),
              SizedBox(width: 12),
              Text(
                'Preferences',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ]),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Preferred Language:'),
                Text("English"),
                // DropdownButton<String>(
                //   value: Preferences.preferredLanguage,
                //   items: Language.all.map((language) {
                //     return DropdownMenuItem(
                //       value: language.code,
                //       child: Text(language.name),
                //     );
                //   }).toList(),
                //   onChanged: (String? code) {
                //     Preferences.preferredLanguage =
                //         code ?? Language.english.code;
                //     setState(() {});
                //   },
                // ),
              ],
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Preferred Bible Version:'),
              DropdownButton<String>(
                value: Preferences.preferredVersion,
                items: Translation.all.map((Translation version) {
                  return DropdownMenuItem(
                    value: version.code,
                    child: Text(version.short),
                  );
                }).toList(),
                onChanged: (String? selected) {
                  Preferences.preferredVersion =
                      selected ?? Translation.web.code;
                  setState(() {});
                },
              ),
            ]),
          ])),
    );
  }
}
