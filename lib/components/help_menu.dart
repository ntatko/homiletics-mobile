import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpMenu extends StatelessWidget {
  const HelpMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Column(children: [
          Center(
              child: Text("Copyright (C) ${DateTime.now().year} 13one.org",
                  style: const TextStyle(color: Colors.grey))),
          const Center(
              child: Text("All rights reserved",
                  style: TextStyle(color: Colors.grey))),
          // TextButton(
          //     onPressed: () => _sendEmail(),
          //     child: const Text("Report a problem"))
        ]));
  }
}

_sendEmail() async {
  const url = "mailto:stlyabsf+support@gmail.com?subject=Support%20Request";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw "could not launch $url";
  }
}
