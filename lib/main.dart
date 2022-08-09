import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do_list/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late TextEditingController _controller;
  bool value = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void addTask(String data) async {
    if(_controller.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('Items').add(
          {'task': data, 'done': false, 'time': Timestamp.now()});
      FocusManager.instance.primaryFocus?.unfocus();
      _controller.clear();
    } else{
      await showDialog(
        context: context,
        builder: (BuildContext context){
          return const AlertDialog(
            content: Text('Please type something'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: secondary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: secondary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: width*0.6,
                    height: height*0.15,
                    child: TextField(
                      textCapitalization: TextCapitalization.sentences,
                      style: GoogleFonts.ptSans(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter task here',
                        hintStyle: GoogleFonts.ptSans(fontSize: 24, fontWeight: FontWeight.bold, color: accent),
                        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accent),),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: accent),),
                      ),
                      controller: _controller,
                      onSubmitted: (String value)=> addTask(_controller.text)
                    ),
                  ),
                  const SizedBox(width: 20,),
                  ElevatedButton(
                    onPressed: ()=> addTask(_controller.text),
                    child: Text('Add', style: GoogleFonts.ptSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height*0.7,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("Items").orderBy('time', descending: true).snapshots(),
                  builder: (context, snapshot){
                    return !snapshot.hasData ? Text('Loading...', style: GoogleFonts.ptSans(fontSize: 20, fontWeight: FontWeight.bold, color: accent),) : ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index){
                        bool check = snapshot.data!.docs[index]['done'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                            decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(20)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: width*0.6,
                                  child: Text(snapshot.data!.docs[index]['task'], style: GoogleFonts.ptSans(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis,),
                                ),
                                Checkbox(
                                  value: check,
                                  checkColor: Colors.white,
                                  shape: const CircleBorder(),
                                  side: MaterialStateBorderSide.resolveWith(
                                        (states) => const BorderSide(width: 2.0, color: Colors.blue),
                                  ),
                                  onChanged: (bool? value) {
                                    FirebaseFirestore.instance.collection('Items').doc(snapshot.data!.docs[index].id).update({'done' : value});
                                    setState(() {
                                      check = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
