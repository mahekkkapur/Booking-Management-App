import 'dart:async';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:econoomaccess/models/message.dart';
import 'package:flutter/material.dart';
import 'package:wakelock/wakelock.dart';

class JoiningSessionPage extends StatefulWidget {
  final String channelName;
  final int channelId;
  final String username;
  final String hostImage;
  final String userImage;
  final String uid;

  const JoiningSessionPage(
      {Key key,
      @required this.channelName,
      @required this.channelId,
      @required this.username,
      @required this.hostImage,
      @required this.uid,
      @required this.userImage})
      : super(key: key);

  @override
  _JoiningSessionPageState createState() => _JoiningSessionPageState();
}

class _JoiningSessionPageState extends State<JoiningSessionPage> {
  final String appId = "404fe026895e48dd81cbad1b27af6a0e";
  bool permit = false;

  bool loading = true;
  bool completed = false;
  static final _users = <int>[];
  bool muted = true;
  int userNo = 0;
  var userMap;
  bool heart = false;

  bool _isLogin = true;
  bool _isInChannel = true;

  final _channelMessageController = TextEditingController();

  final _infoStrings = <Message>[];

  AgoraRtmClient _client;
  AgoraRtmChannel _channel;

  var len;

  @override
  void dispose() {
    _users.clear();
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initialize();
    userMap = {widget.username: widget.userImage};
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
    await AgoraRtcEngine.muteLocalAudioStream(muted);
    await AgoraRtcEngine.enableLocalVideo(!muted);
  }

  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      Wakelock.enable();
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      if (uid == widget.channelId) {
        setState(() {
          completed = true;
          Future.delayed(const Duration(milliseconds: 1500), () async {
            await Wakelock.disable();
            Navigator.pop(context);
          });
        });
      }
      _users.remove(uid);
    };
  }

  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [];
    _users.forEach((int channelId) {
      if (channelId == widget.channelId) {
        list.add(AgoraRenderWidget(channelId));
      }
    });
    if (list.isEmpty) {
      setState(() {
        loading = true;
      });
    } else {
      setState(() {
        loading = false;
      });
    }

    return list;
  }

  Widget _videoView(view) {
    return Expanded(child: ClipRRect(child: view));
  }

  Widget viewRows() {
    final views = _getRenderViews();
    return (loading == true) && (completed == false)
        ? LoadingPage()
        : Container(
            child: Column(
            children: <Widget>[_videoView(views[0])],
          ));
  }

  Widget _messageList() {
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

  Future<bool> _willPopCallback() async {
    await Wakelock.disable();
    _leaveChannel();
    _logout();
    AgoraRtcEngine.leaveChannel();
    AgoraRtcEngine.destroy();
    return true;
  }

  Widget _ending() {
    return Container(
      color: Colors.black.withOpacity(.7),
      child: Center(
          child: Container(
        width: double.infinity,
        color: Colors.grey[700],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Text(
            'The Live has ended',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
        ),
      )),
    );
  }

  Widget liveText() {
    return Container(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                width: 10,
              ),
              GestureDetector(
                  onTap: () {
                    _willPopCallback();
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget username() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              width: 30.0,
              height: 30.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: NetworkImage(widget.hostImage), fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
              child: Text(
                '${widget.channelName}',
                style: TextStyle(
                    shadows: [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(0, 1.3),
                      ),
                    ],
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  getApproval() async {
    var data = await Firestore.instance
        .collection("liveuser")
        .document(widget.channelName)
        .collection("users")
        .document(widget.uid)
        .get();
    if (!mounted) return;
    setState(() {
      permit = data["approval"];
    });
  }

  @override
  Widget build(BuildContext context) {
    getApproval();
    return WillPopScope(
        child: permit
            ? SafeArea(
                child: Scaffold(
                body: Container(
                  color: Colors.black,
                  child: Center(
                    child: (completed == true)
                        ? _ending()
                        : Stack(
                            children: <Widget>[
                              viewRows(),
                              if (completed == false) _bottomBar(),
                              username(),
                              liveText(),
                              if (completed == false) _messageList(),
                            ],
                          ),
                  ),
                ),
              ))
            : Scaffold(
                body: Container(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [Text("Wait for approval")],
                ),
              )),
        onWillPop: _willPopCallback);
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
                  textInputAction: TextInputAction.go,
                  onSubmitted: _sendMessage,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  controller: _channelMessageController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Add Something',
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: BorderSide(color: Colors.white)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50.0),
                        borderSide: BorderSide(color: Colors.white)),
                  )),
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
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
      _log(user: widget.username, info: text, type: 'message');
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
    _client.onMessageReceived = (AgoraRtmMessage message, String peerId) async {
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
    await _client.login(null, widget.username);
    _channel = await _createChannel(widget.channelName);
    await _channel.join();
    var len;
    _channel.getMembers().then((value) {
      len = value.length;
      setState(() {
        userNo = len - 1;
      });
    });
  }

  Future<AgoraRtmChannel> _createChannel(String name) async {
    AgoraRtmChannel channel = await _client.createChannel(name);
    channel.onMemberJoined = (AgoraRtmMember member) async {
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
        (AgoraRtmMessage message, AgoraRtmMember member) async {
      _log(user: member.userId, info: message.text, type: 'message');
    };
    return channel;
  }

  void _log({String info, String type, String user}) {
    var image = userMap[user];
    Message m =
        new Message(message: info, type: type, user: user, image: image);
    setState(() {
      _infoStrings.insert(0, m);
    });
  }
}

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 10.0),
                Text(
                  'Loading',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 18.0),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
