import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:intl/intl.dart';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mock24x7/MockInfo.dart';
import 'package:mock24x7/MockModel.dart';
import 'package:mock24x7/MockModelManager.dart';
import 'package:mock24x7/TestWork.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';

var mockModelList = MockModelManager.getMockModels(); // Retrieve saved models



void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;
  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print("REsume");
      setState(() {
        mockModelList = MockModelManager.getMockModels();
        
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mock 24x7',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.cabinTextTheme(
          Theme.of(context).textTheme,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.blue[50],
          hintStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: GoogleFonts.cabinTextTheme(
          Theme.of(context).textTheme.apply(bodyColor: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[800],
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
          contentPadding:
              EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      themeMode: _themeMode, // Current theme mode based on state
      home: MyHomePage(
        toggleTheme: _toggleTheme,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final VoidCallback toggleTheme;

  MyHomePage({required this.toggleTheme});
  final TextEditingController topicController = TextEditingController();
  final TextEditingController difficultyController = TextEditingController();
  int selectedNumber = 10;

  @override
  Widget build(BuildContext context) {
    void _showLoadingDialog() {
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Generating Mock. It may take a minute..."),
              ],
            ),
          );
        },
      );
    }

    void _generateButtonPressed() async {
      // Retrieve the necessary parameters
      String topic = topicController.text;
      String difficulty = difficultyController.text;

      if (topic == null ||
          topic == '' ||
          difficulty == null ||
          difficulty == "" ||
          selectedNumber <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill all the fiels to continue.')),
        );
        return;
      }

      // Show loading dialog
      _showLoadingDialog();

      // Call the async function to generate mock and wait for the result
      var _newmockmodel =
          await _generateMock(topic, difficulty, selectedNumber);

      // Close the loading dialog
      Navigator.pop(context);

      if (_newmockmodel != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SuccessScreen(_newmockmodel)),
        );
      } else {
        Navigator.pop(context);
        CoolAlert.show(
            title: "Something went wrong!!",
            confirmBtnText: "Ok",
            showCancelBtn: true,
            context: context,
            width: 400.0,
            animType: CoolAlertAnimType.slideInDown,
            type: CoolAlertType.error,
            text:
                "Some Problem occurs while generating mock. Try Again\n\nTips: Sometime it occurs due to max questions.So, try to generate less question from maximum question.",
            confirmBtnColor: Color.fromARGB(255, 31, 77, 216));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mock 24x7', style: GoogleFonts.cabin()),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: toggleTheme, // Toggle light/dark mode
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   height: 250.0,
              //   'assetss/Banner.jpg',
              //   fit: BoxFit.cover,
              // ),

              // Large App Name
              Text(
                "Mock 24x7",
                style: GoogleFonts.cabin(
                  textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              SizedBox(height: 40),

              // Pill-shaped Text Bar for Topic
              Container(
                width: 1000,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: topicController,
                  decoration: InputDecoration(
                      hintText: "Write your topic...",
                      hintStyle: TextStyle(fontSize: 23)),
                  style: TextStyle(fontSize: 23),
                ),
              ),
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Small Text Bar for Difficulty
                  Container(
                    width: 300,
                    decoration: const BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: difficultyController,
                      decoration: InputDecoration(
                        hintText: "Set Difficulty: Class 10, Hard, etc..",
                      ),
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Dropdown for selecting number (1 to 50)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Select Number Of Questions:",
                        style: GoogleFonts.cabin(
                          textStyle: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      SizedBox(width: 10),
                      StatefulBuilder(builder: (context, innerstate) {
                        return DropdownButton<int>(
                          value: selectedNumber,
                          dropdownColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          items: List.generate(20, (index) => index + 1)
                              .map<DropdownMenuItem<int>>((int value) {
                            return DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString(),
                                  style: Theme.of(context).textTheme.bodyLarge),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            innerstate(() {
                              selectedNumber = newValue!;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 50.0,
              ),
              Center(
                child: Text(
                  "HISTORY",
                  style: GoogleFonts.cabin(
                      fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
              Expanded(
                flex: 8,
                child: FutureBuilder<List<Mockmodel>>(
                  future: mockModelList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      print(snapshot.error.toString());
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No history found.'));
                    } else {
                      final quizzes = snapshot.data!;
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: ListView.builder(
                          itemCount: quizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = quizzes[index];
                            return GestureDetector(
                                onTap: () {
                                  // Navigate to the quiz screen and pass the selected MockModel
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SuccessScreen(quiz),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(25.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Title and Date row
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              quiz.Topic,
                                              style: TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                _buildInfoItem(
                                                  Icons.access_time,
                                                  'Date Generate',
                                                  quiz.Date_Generated.year <
                                                          2020
                                                      ? 'Date Not Found'
                                                      : DateFormat(
                                                              'MMM dd, yyyy')
                                                          .format(quiz
                                                              .Date_Generated)
                                                          .toString(),

                                                  //  DateFormat("MMM dd, yyyy")
                                                  //     .format(quiz
                                                  //         .Date_Generated)
                                                  //     .toString()
                                                ),
                                                SizedBox(
                                                  width: 30.0,
                                                ),
                                                _buildInfoItem(
                                                  Icons.access_time,
                                                  'Last Attempt',
                                                  quiz.LastDate_Attempt.year <
                                                          2020
                                                      ? 'Date Not Found'
                                                      : DateFormat(
                                                              'MMM dd, yyyy')
                                                          .format(quiz
                                                              .LastDate_Attempt)
                                                          .toString(),
                                                ),
                                                SizedBox(
                                                  width: 30.0,
                                                ),
                                                _buildInfoItem(
                                                    Icons.question_answer,
                                                    'Total Questions',
                                                    quiz.QNA.length.toString()),
                                                SizedBox(
                                                  width: 30.0,
                                                ),
                                                _buildInfoItem(
                                                    Icons.timer,
                                                    'Timer',
                                                    (quiz.Timer_Time == 0)
                                                        ? "No timer"
                                                        : quiz.Timer_Time
                                                                .toString() +
                                                            " Min"),
                                                SizedBox(
                                                  width: 30.0,
                                                ),
                                                _buildInfoItem(
                                                  Icons.check_circle,
                                                  'Correct',
                                                  quiz.Num_Correct_MCQ
                                                          .toString() +
                                                      "/" +
                                                      quiz.QNA.length
                                                          .toString(),
                                                  correctColor: Colors.green,
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        // SizedBox(height: 16),
                                        // Grid with 4 items
                                        // Padding(
                                        //   padding: EdgeInsets.all(50.0),
                                        //   child: Center(
                                        //     child: GridView.count(
                                        //       crossAxisCount: 4,
                                        //       shrinkWrap: true,
                                        //       physics:
                                        //           NeverScrollableScrollPhysics(),
                                        //       crossAxisSpacing: 16,
                                        //       mainAxisSpacing: 16,
                                        //       children: [
                                        //         _buildInfoItem(
                                        //             Icons.access_time,
                                        //             'Last Attempt',
                                        //             quiz.LastDate_Attempt.year
                                        //                 .toString()),
                                        //         _buildInfoItem(
                                        //             Icons.question_answer,
                                        //             'Total Questions',
                                        //             quiz.QNA.length.toString()),
                                        //         _buildInfoItem(Icons.timer, 'Timer',
                                        //             (quiz.Timer_Time==0)?"No timer" : quiz.Timer_Time.toString()+" Min"),
                                        //         _buildInfoItem(
                                        //           Icons.check_circle,
                                        //           'Correct',
                                        //           quiz.Num_Correct_MCQ.toString() +
                                        //               "/" +
                                        //               quiz.QNA.length.toString(),
                                        //           correctColor: Colors.green,
                                        //         ),
                                        //       ],
                                        //     ),
                                        //   ),
                                        // )
                                      ],
                                    ),
                                  ),
                                ));
                            // Card(
                            //   child: ListTile(
                            //     title: Text(quiz.Topic),
                            //     subtitle: Text('${quiz.QNA.length} questions'),
                            //     onTap: () {
                            //       // Navigate to the quiz screen and pass the selected MockModel
                            //       Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //           builder: (context) => SuccessScreen(quiz),
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // Generate Button at Bottom Left
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _generateButtonPressed();
          // Handle button press
        },
        label: Text(
          "Generate",
          style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18.0),
        ),
        icon: Icon(
          Icons.play_arrow_rounded,
          size: 30.0,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value,
      {Color correctColor = Colors.white}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue, size: 30), // Adjust size if needed
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(width: 10), // Space between label and value
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: label == 'Correct' ? correctColor : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future _generateMock(String topic, String difficulty, int number) async {
    String cmd = Testwork().cmdGenerater(topic, difficulty, number.toString());
    print(cmd);
    String QNA_string = await Testwork().runPythonShell(cmd);
    if (QNA_string == "" || QNA_string == null) {
      QNA_string = await Testwork().runPythonShell(cmd);
      if (QNA_string == "" || QNA_string == null) {
        return;
      }
    }
    var _temp_QNA;
    print(QNA_string);
    try {
      _temp_QNA = jsonDecode(QNA_string).cast<Map<String, dynamic>>();
    } catch (E) {
      print("Error: " + E.toString());
      return;
    }

    Mockmodel _newmockmodel = Mockmodel(
      id: Random().nextInt(180000),
      Topic: topic,
      Difficulty: difficulty,
      Num_MCQ: number,
      QNA: (_temp_QNA == null) ? List.empty() : _temp_QNA,
      Num_Correct_MCQ: 0,
      Num_attempt_MCQ: 0,
      Num_Incorrect_MCQ: 0,
      LastDate_Attempt: DateTime(1900),
      Date_Generated: DateTime.now(),
      IsTimer: false,
      Timer_Time: 0,
    );

    await MockModelManager.saveMockModel(_newmockmodel);

    return _newmockmodel;
  }
}
