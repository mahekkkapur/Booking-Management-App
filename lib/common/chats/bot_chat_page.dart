import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_dialogflow_v2/flutter_dialogflow_v2.dart' as df;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';

class BotChat extends StatefulWidget {
  final String uid;
  final bool isUser;

  const BotChat(this.uid, this.isUser);

  @override
  _BotChatState createState() => _BotChatState();
}

class _BotChatState extends State<BotChat> {
  final messageController = TextEditingController();
  List<Widget> _messages = List<Widget>();
  df.AuthGoogle _authGoogle;
  df.Dialogflow _dialogflow;
  bool micListening = false;
  String session;
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "";
  DocumentSnapshot docSnap;
  final SpeechToText speech = SpeechToText();
  List options = [];
  Map payload;
  Timer twentyTimer;

  @override
  void initState() {
    super.initState();
    initSpeechState();
    dialoginit();
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  void requestPermission() async {
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone);

    if (permission != PermissionStatus.granted) {
      await PermissionHandler()
          .requestPermissions([PermissionGroup.microphone]);
    }
  }

  void dialoginit() async {
    String collection = widget.isUser ? "users" : "homemakers";
    DocumentSnapshot documentSnapshot = await Firestore.instance
        .collection(collection)
        .document(widget.uid)
        .get();
    setState(() {
      docSnap = documentSnapshot;
    });
    List result = await getSession();
    callTimer(result[0]);
    _authGoogle = await df.AuthGoogle(fileJson: "assets/bot.json").build();
    _dialogflow = df.Dialogflow(authGoogle: _authGoogle);
    if (!mounted) return;
    setState(() {
      payload = result[1];
      _messages.insert(
          0,
          widgetMessage(
              "Hi,this is naaniz bot, Type Hi to start chatting", false));
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    twentyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "Naaniz Kitchen",
            style: TextStyle(
                color: Color(0xffFE506D),
                fontWeight: FontWeight.w900,
                fontSize: 24,
                fontFamily: "Gilroy"),
          ),
          actions: [
            IconButton(icon: Icon(Icons.info_outline), onPressed: () {})
          ],
        ),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                  child: Container(
                child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20.0, 20, 20, 10),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => _messages[index]),
              )),
              Container(
                  height: 30,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => sendMessage(options[index]),
                          child: Container(
                              margin: EdgeInsets.only(right: 10),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.blue,
                                      width: 1.5,
                                      style: BorderStyle.solid)),
                              child: Text(
                                options[index].toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "Gilroy",
                                    fontWeight: FontWeight.w300),
                              )),
                        );
                      })),
              SizedBox(
                height: 10,
              ),
              Container(
                  padding:
                      const EdgeInsets.only(left: 20.0, bottom: 20, right: 10),
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            child: TextField(
                          style: TextStyle(color: Colors.black26),
                          decoration: InputDecoration(
                            prefixIcon: GestureDetector(
                              child: micListening
                                  ? Icon(Icons.mic_off)
                                  : Icon(Icons.mic),
                              onTap: () {
                                if (micListening) {
                                  setState(() {
                                    micListening = !micListening;
                                  });
                                  if (speech.isListening) {
                                    stopListening();
                                  }
                                } else {
                                  requestPermission();
                                  setState(() {
                                    micListening = !micListening;
                                  });
                                  if (!(!_hasSpeech || speech.isListening)) {
                                    startListening();
                                  }
                                }
                              },
                            ),
                            hintText: micListening
                                ? "Listening voice....."
                                : 'Send message',
                            hintStyle: TextStyle(
                              color: Color.fromRGBO(38, 50, 56, 0.30),
                              fontSize: 15.0,
                              fontFamily: "Gilroy",
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(6.0)),
                            ),
                          ),
                          controller: messageController,
                        )),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () => sendMessage(messageController.text),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Color(0xffFE506D),
                                borderRadius: BorderRadius.circular(40)),
                            child: Transform.rotate(
                                angle: -math.pi / 6,
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 24,
                                )),
                          ),
                        ),
                      ]))
            ]));
  }

  widgetMessage(String message, bool myMessage, {func = false, String route}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: func
            ? () {
                Navigator.pushNamedAndRemoveUntil(
                    context, route, (route) => false);
              }
            : null,
        child: messageText(message, myMessage, link: func),
      ),
    );
  }

  messageText(String message, bool myMessage, {bool link = false}) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment:
            myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: myMessage
                ? const EdgeInsets.fromLTRB(50, 10, 10, 10)
                : const EdgeInsets.fromLTRB(10, 10, 50, 10),
            child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Text(
                  "$message",
                  style: TextStyle(
                      color: myMessage
                          ? Colors.black
                          : link ? Colors.yellowAccent : Colors.white,
                      fontFamily: "Gilroy",
                      decoration: link
                          ? TextDecoration.underline
                          : TextDecoration.none),
                ),
                decoration: BoxDecoration(
                    color: myMessage
                        ? Colors.black26.withOpacity(0.05)
                        : Color(0xffFE506D),
                    borderRadius: BorderRadius.all(Radius.circular(10)))),
          )
        ]);
  }

  sendMessage(String message) async {
    String response;
    bool func = false;
    bool recommend = false;
    Map routes = {
      "Sure, Click here to order food.": "/BottomBarPage",
    };
    if (message == null || message.isEmpty) return;
    setState(() {
      _messages.insert(0, widgetMessage(message, true));
    });
    messageController.clear();
    df.DetectIntentResponse res =
        await _dialogflow.detectIntent(df.DetectIntentRequest(
      queryInput: df.QueryInput(
          text: df.TextInput(text: message, languageCode: df.Language.english)),
      queryParams: df.QueryParameters(payload: payload),
    ));

    String responseText = res.queryResult.fulfillmentText;
    if (message.toLowerCase() == "recommend food".toLowerCase())
      recommend = true;
    if (routes[responseText] != null) func = true;
    setState(() {
      response = responseText;
      options = res.queryResult.fulfillmentMessages.length > 1
          ? res.queryResult.fulfillmentMessages[1].toJson()["payload"]
              ["options"]
          : [];

      _messages.insert(
          0,
          widgetMessage(response, false,
              func: func, route: routes[responseText]));
      if (recommend)
        _messages.insert(
            0,
            widgetMessage("Click here to order.", false,
                func: true, route: "/BottomBarPage"));
    });
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 10),
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      cancelOnError: true,
      partialResults: true,
    );

    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = "${result.recognizedWords}";
      setState(() {
        messageController.text = lastWords;
      });
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = math.min(minSoundLevel, level);
    maxSoundLevel = math.max(maxSoundLevel, level);
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    Fluttertoast.showToast(msg: status);
    setState(() {
      lastStatus = "$status";
      if ("$status" == "notListening") {
        setState(() {
          micListening = false;
        });
      }
    });
  }

  Future<List> getSession() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int diff;
    String id = pref.getString("session");
    String stringTime = pref.getString("expiry");
    Map jsonResult;
    if (stringTime == null) {
      diff = 0;
    } else {
      DateTime now = DateTime.now();
      DateTime expiry =
          (stringTime == null) ? null : DateTime.parse(stringTime);
      diff = now.difference(expiry).inMinutes;
      print(diff);
    }
    if (id == null || diff > 15) {
      http.Response res = await http.post(
          "https://naniz-webhook.herokuapp.com/chat/api/customer-session",
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
            {
              'prevSessionId': id,
              'mobileNumber': docSnap.data["mobileno"],
              'customerType': widget.isUser ? "user" : "homemaker",
            },
          ));
      try {
        jsonResult = jsonDecode(res.body);
        id = jsonResult["customerSessionId"];
        stringTime = DateTime.now().toString();
        pref.setString("session", id);
        pref.setString("expiry", stringTime);
        pref.setString("result", json.encode(jsonResult));
      } catch (se) {
        id = "Session server error";
        print("Session server error");
      }
    } else {
      jsonResult = jsonDecode(pref.getString("result"));
    }
    return [diff, jsonResult];
  }

  callTimer(int diff) {
    Timer(Duration(minutes: 19 - diff), () async {
      print('first timer c all');
      final result = await getSession();
      if (!mounted) return;
      setState(() {
        payload = result[1];
        twentyTimer = call20Timer();
      });
    });
  }

  Timer call20Timer() {
    return Timer.periodic(Duration(minutes: 20), (_) async {
      print("next Timer call");
      final result = await getSession();
      setState(() {
        payload = result[1];
      });
    });
  }
}
