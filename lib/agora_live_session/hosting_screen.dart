import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/models/message.dart';
import 'package:econoomaccess/agora_live_session/approval_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/firestore_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:wakelock/wakelock.dart';

class HostingPage extends StatefulWidget {
  final String channelName;

  final String image;
  final time;
  final String name;

  const HostingPage(
      {Key key, this.channelName, this.time, this.image, this.name})
      : super(key: key);

  @override
  _HostingPageState createState() => _HostingPageState();
}

class _HostingPageState extends State<HostingPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  static final _users = <int>[];
  String channelName;

  bool muted = false;
  bool _isLogin = true;
  bool _isInChannel = true;
  int userNo = 0;
  var userMap;
  var tryingToEnd = false;

  bool showList = false;

  final String appId = "404fe026895e48dd81cbad1b27af6a0e";

  final _channelMessageController = TextEditingController();

  final _infoStrings = <Message>[];

  AgoraRtmClient _client;
  AgoraRtmChannel _channel;
  bool heart = false;

  Timer _timer;

  @override
  void dispose() {
    _users.clear();
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initialize();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    userMap = {widget.channelName: widget.image};
    _createClient();
  }

  Future<void> initialize() async {
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await AgoraRtcEngine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await AgoraRtcEngine.joinChannel(null, widget.channelName, null, 0);
  }

  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create(appId);
    await AgoraRtcEngine.enableVideo();
  }

  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) async {
      final documentId = widget.channelName;
      channelName = documentId;
      FirestoreService.createLiveUser(
          name: documentId,
          id: uid,
          time: widget.time,
          image: widget.image,
          organiser: widget.name);

      await Wakelock.enable();

      setState(() {});
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        _users.remove(uid);
      });
    };
  }

  List<Widget> _getRenderViews() {
    final list = [
      AgoraRenderWidget(0, local: true, preview: true),
    ];
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: ClipRRect(child: view));
  }

  Widget _viewRows() {
    final views = _getRenderViews();
    return Container(
        child: Column(
      children: <Widget>[_videoView(views[0])],
    ));
  }

  void popUp() async {
    setState(() {
      heart = true;
    });

    _timer = Timer.periodic(Duration(milliseconds: 125), (Timer t) {
      setState(() {});
    });

    Timer(
        Duration(seconds: 4),
        () => {
              _timer.cancel(),
              setState(() {
                heart = false;
              })
            });
  }

  Widget messageList() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: (_infoStrings[index].type == 'join')
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 32.0,
                              height: 32.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image:
                                        NetworkImage(_infoStrings[index].image),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                '${_infoStrings[index].user} joined',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : (_infoStrings[index].type == 'message')
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 32.0,
                                  height: 32.0,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            _infoStrings[index].image),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        _infoStrings[index].user,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Text(
                                        _infoStrings[index].message,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        : null,
              );
            },
          ),
        ),
      ),
    );
  }

  bool pop = false;

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  Future<bool> _willPopCallback() async {
    setState(() {
      tryingToEnd = true;
    });
    return false;
  }

  Widget _endCall() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                showList = !showList;
                if (showList) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              });
            },
            child: AnimatedIcon(
                icon: AnimatedIcons.view_list, progress: _controller),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  tryingToEnd = true;
                });
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.redAccent),
                child: Text(
                  'End Session',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _liveText() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Colors.pink, Colors.red],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(4.0))),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
                child: Text(
                  widget.channelName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget endLive() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Text(
                'Are you sure you want to end your live session?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8.0, right: 4.0, top: 8.0, bottom: 8.0),
                    child: RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'End Video',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      elevation: 2.0,
                      color: Colors.pink,
                      onPressed: () async {
                        await Wakelock.disable();
                        _logout();
                        _leaveChannel();
                        AgoraRtcEngine.leaveChannel();
                        AgoraRtcEngine.destroy();
                        FirestoreService.deleteUser(username: channelName);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 4.0, right: 8.0, top: 8.0, bottom: 8.0),
                    child: RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      elevation: 2.0,
                      color: Colors.grey,
                      onPressed: () {
                        setState(() {
                          tryingToEnd = false;
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: SafeArea(
          child: Scaffold(
            body: Container(
              color: Colors.black,
              child: Center(
                child: Stack(
                  children: <Widget>[
                    _viewRows(),
                    if (tryingToEnd == false) _endCall(),
                    if (tryingToEnd == false) _liveText(),
                    if (tryingToEnd == false) _bottomBar(),
                    if (tryingToEnd == false) messageList(),
                    if (tryingToEnd == false) _getApprovalList(),
                    if (tryingToEnd == true) endLive(),
                  ],
                ),
              ),
            ),
          ),
        ),
        onWillPop: _willPopCallback);
  }

  Widget _getApprovalList() {
    return showList
        ? Positioned(
            right: 0,
            child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(top: 100, bottom: 100, right: 10),
              width: 200,
              height: MediaQuery.of(context).size.height,
              child: StreamBuilder(
                  stream: Firestore.instance
                      .collection("liveuser")
                      .document(widget.channelName)
                      .collection("users")
                      .snapshots(),
                  builder: (context, snapshot) {
                    Fluttertoast.showToast(msg: snapshot.hasData.toString());
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            if (snapshot.data.documents[index]["approval"]) {
                              return SizedBox();
                            } else {
                              return Approval(
                                  name: snapshot.data.documents[index]["name"],
                                  channelName: widget.channelName,
                                  imageUrl: snapshot.data.documents[index]
                                      ["image"],
                                  uid: snapshot.data.documents[index]["uid"]);
                            }
                          });
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("There are no user who is requesting"),
                      );
                    } else {
                      return Center(
                        child: Text("There are no user who is requesting"),
                      );
                    }
                  }),
            ),
          )
        : SizedBox();
  }

  Widget _bottomBar() {
    if (!_isLogin || !_isInChannel) {
      return Container();
    }
    return Container(
      alignment: Alignment.bottomRight,
      child: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 5, right: 8, bottom: 5),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
            new Expanded(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0, 0, 0),
              child: new TextField(
                  cursorColor: Colors.red,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _sendMessage,
                  style: TextStyle(color: Colors.white),
                  controller: _channelMessageController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Add Something',
                    hintStyle:
                        TextStyle(color: Colors.white, fontFamily: "Gilroy"),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: BorderSide(color: Colors.white)),
                  )),
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: _toggleSendChannelMessage,
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                color: Colors.pinkAccent[400],
                padding: const EdgeInsets.all(12.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: _onToggleMute,
                child: Icon(
                  muted ? Icons.mic_off : Icons.mic,
                  color: muted ? Colors.white : Colors.pinkAccent[400],
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                color: muted ? Colors.pinkAccent[400] : Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
              child: MaterialButton(
                minWidth: 0,
                onPressed: _onSwitchCamera,
                child: Icon(
                  Icons.switch_camera,
                  color: Colors.pinkAccent[400],
                  size: 20.0,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                color: Colors.white,
                padding: const EdgeInsets.all(12.0),
              ),
            )
          ]),
        ),
      ),
    );
  }

  void _logout() async {
    try {
      await _client.logout();
    } catch (errorCode) {}
  }

  void _leaveChannel() async {
    try {
      await _channel.leave();
      _client.releaseChannel(_channel.channelId);
      _channelMessageController.text = null;
    } catch (errorCode) {}
  }

  void _toggleSendChannelMessage() async {
    String text = _channelMessageController.text;
    if (text.isEmpty) {
      return;
    }
    try {
      _channelMessageController.clear();
      await _channel.sendMessage(AgoraRtmMessage.fromText(text));
      _log(user: widget.channelName, info: text, type: 'message');
    } catch (errorCode) {}
  }

  void _sendMessage(text) async {
    if (text.isEmpty) {
      return;
    }
    try {
      _channelMessageController.clear();
      await _channel.sendMessage(AgoraRtmMessage.fromText(text));
      _log(user: widget.channelName, info: text, type: 'message');
    } catch (errorCode) {}
  }

  void _createClient() async {
    _client =
        await AgoraRtmClient.createInstance('404fe026895e48dd81cbad1b27af6a0e');
    _client.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      _log(user: peerId, info: message.text, type: 'message');
    };
    _client.onConnectionStateChanged = (int state, int reason) {
      if (state == 5) {
        _client.logout();
        setState(() {
          _isLogin = false;
        });
      }
    };
    await _client.login(null, widget.channelName);
    _channel = await _createChannel(widget.channelName);
    await _channel.join();
  }

  Future<AgoraRtmChannel> _createChannel(String name) async {
    AgoraRtmChannel channel = await _client.createChannel(name);
    channel.onMemberJoined = (AgoraRtmMember member) async {
      var len;
      _channel.getMembers().then((value) {
        len = value.length;
        setState(() {
          userNo = len - 1;
        });
      });

      _log(info: 'Member joined: ', user: member.userId, type: 'join');
    };
    channel.onMemberLeft = (AgoraRtmMember member) {
      var len;
      _channel.getMembers().then((value) {
        len = value.length;
        setState(() {
          userNo = len - 1;
        });
      });
    };
    channel.onMessageReceived =
        (AgoraRtmMessage message, AgoraRtmMember member) {
      _log(user: member.userId, info: message.text, type: 'message');
    };
    return channel;
  }

  void _log({String info, String type, String user}) {
    if (type == 'message' && info.contains('m1x2y3z4p5t6l7k8')) {
      popUp();
    } else {
      var image = userMap[user];
      Message m =
          new Message(message: info, type: type, user: user, image: image);
      setState(() {
        _infoStrings.insert(0, m);
      });
    }
  }
}
