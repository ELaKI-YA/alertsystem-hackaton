import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(TrackifyApp());
}

class TrackifyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Trackify",
      theme: ThemeData.dark(),
      home: SplashScreen(),
    );
  }
}

String language = "en";
String gender = "";

String name = "";
String dob = "";
String blood = "";
String email = "";
String phone = "";

File? photo;

List<String> alertNumbers = ["100","1515"]

String tr(String en, String ta) {
  return language == "ta" ? ta : en;
}

////////////////////////////////////////////////////////////
/// SPLASH SCREEN
////////////////////////////////////////////////////////////

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String text = "";
  String word = "TRACKIFY";
  int index = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (index < word.length) {
        setState(() {
          text += word[index];
          index++;
        });
      } else {
        timer.cancel();
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => LanguageScreen()),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// LANGUAGE SCREEN
////////////////////////////////////////////////////////////

class LanguageScreen extends StatelessWidget {
  void selectLanguage(BuildContext context, String lang) {
    language = lang;

    Navigator.push(context, MaterialPageRoute(builder: (_) => TermsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tr("Select Language", "மொழியை தேர்வு செய்யவும்"),
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => selectLanguage(context, "en"),
              child: Text("English"),
            ),
            ElevatedButton(
              onPressed: () => selectLanguage(context, "ta"),
              child: Text("தமிழ்"),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// TERMS SCREEN
////////////////////////////////////////////////////////////

class TermsScreen extends StatefulWidget {
  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool accepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr("Terms & Conditions", "விதிமுறைகள்"))),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
              ),
              child: Text(
                tr(
                  "Use Sentinel only during real emergencies.\n\nEnable location services while sending alerts.\n\nFollow driver instructions during emergencies.\n\nDo not misuse the emergency alert system.\n\nDo not damage safety monitoring devices.",
                  "Sentinel அம்சத்தை அவசரநிலையில் மட்டும் பயன்படுத்தவும்.\n\nஅவசர அறிவிப்பை அனுப்பும்போது இடம் இயக்கப்பட்டிருக்க வேண்டும்.\n\nஅவசரநிலையில் டிரைவரின் வழிமுறைகளை பின்பற்றவும்.\n\nஅவசர எச்சரிக்கை அமைப்பை தவறாக பயன்படுத்த வேண்டாம்.\n\nபாதுகாப்பு சாதனங்களை சேதப்படுத்த வேண்டாம்.",
                ),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: accepted,
                  onChanged: (v) {
                    setState(() {
                      accepted = v!;
                    });
                  },
                ),
                Text(tr("Accept Terms", "விதிமுறைகளை ஏற்கிறேன்")),
              ],
            ),
            ElevatedButton(
              onPressed: accepted
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => GenderScreen()),
                      );
                    }
                  : null,
              child: Text(tr("Continue", "தொடரவும்")),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// GENDER
////////////////////////////////////////////////////////////

class GenderScreen extends StatelessWidget {
  void select(BuildContext context, String g) {
    gender = g;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("Select Gender", "பாலினத்தை தேர்வு செய்யவும்")),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => select(context, "Male"),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(Icons.man, size: 100), Text(tr("Male", "ஆண்"))],
            ),
          ),
          GestureDetector(
            onTap: () => select(context, "Female"),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.woman, size: 100),
                Text(tr("Female", "பெண்")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// REGISTER SCREEN
////////////////////////////////////////////////////////////

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final bloodController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  Future pickDOB() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      dobController.text = "${date.day}/${date.month}/${date.year}";
    }
  }

  Future pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (img != null) {
      setState(() {
        photo = File(img.path);
      });
    }
  }

  void submit() {
    name = nameController.text;
    dob = dobController.text;
    blood = bloodController.text;
    email = emailController.text;
    phone = phoneController.text;

    Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen()));
  }

  Widget field(String label, TextEditingController c) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr("Passenger Registration", "பயணி பதிவு"))),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            field(tr("Name", "பெயர்"), nameController),
            TextField(
              controller: dobController,
              readOnly: true,
              onTap: pickDOB,
              decoration: InputDecoration(
                labelText: tr("DOB", "பிறந்த தேதி"),
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: 10),
            field(tr("Blood Group", "ரத்த வகை"), bloodController),
            field(tr("Email", "மின்னஞ்சல்"), emailController),
            field(tr("Phone", "தொலைபேசி"), phoneController),
            ElevatedButton(
              onPressed: pickImage,
              child: Text(tr("Upload Photo", "புகைப்படம் பதிவேற்றம்")),
            ),
            SizedBox(height: 10),
            photo != null
                ? Image.file(photo!, height: 120)
                : Text(
                    tr(
                      "No Photo Selected",
                      "புகைப்படம் தேர்வு செய்யப்படவில்லை",
                    ),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submit,
              child: Text(tr("Submit", "சமர்ப்பிக்கவும்")),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// HOME SCREEN
////////////////////////////////////////////////////////////

class HomeScreen extends StatelessWidget {
  void openSentinel(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SentinelScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trackify")),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                route("1", "Maruthamalai", "Avarampalayam"),
                route("1A", "Ondipudur", "Vadavalli"),
                route("3", "Ganapathy", "Madukkarai"),
                route("10", "Saibaba Colony", "Chinniampalayam"),
                route("70", "Gandhipuram", "Maruthamalai"),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.all(20),
            ),
            onPressed: () => openSentinel(context),
            child: Text(tr("⚠ SENTINEL", "⚠ அவசர எச்சரிக்கை")),
          ),
        ],
      ),
    );
  }

  Widget route(String bus, String from, String to) {
    return Card(
      child: ListTile(title: Text("Bus $bus"), subtitle: Text("$from ➜ $to")),
    );
  }
}

////////////////////////////////////////////////////////////
/// SENTINEL SCREEN
////////////////////////////////////////////////////////////

class SentinelScreen extends StatelessWidget {
  Future sendEmergency(String type) async {
    LocationPermission permission = await Geolocator.requestPermission();

    Position pos = await Geolocator.getCurrentPosition();

    String location =
        "https://maps.google.com/?q=${pos.latitude},${pos.longitude}";

    String message =
        "TRACKIFY ALERT\nEmergency:$type\nName:$name\nPhone:$phone\nLocation:$location";

    for (String number in alertNumbers) {
      String sms = "sms:$number?body=${Uri.encodeComponent(message)}";
      await launchUrl(Uri.parse(sms));
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> options = gender == "Female"
        ? [
            tr("Kidnap", "கடத்தல்"),
            tr("Harassment", "துன்புறுத்தல்"),
            tr("Stalking", "பின்தொடர்வு"),
          ]
        : [
            tr("Robbery", "கொள்ளை"),
            tr("Assault", "தாக்குதல்"),
            tr("Medical Emergency", "மருத்துவ அவசரம்"),
          ];

    return Scaffold(
      appBar: AppBar(title: Text(tr("Emergency Options", "அவசர தேர்வுகள்"))),
      body: ListView.builder(
        itemCount: options.length,
        itemBuilder: (_, i) {
          return ListTile(
            leading: Icon(Icons.warning, color: Colors.red),
            title: Text(options[i]),
            onTap: () {
              sendEmergency(options[i]);
            },
          );
        },
      ),
    );
  }
}

