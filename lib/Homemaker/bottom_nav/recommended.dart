import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:econoomaccess/Homemaker/youtube_services/youtube_model.dart';
import 'package:econoomaccess/Homemaker/youtube_services/youtube_api_service.dart';

class Recommended extends StatefulWidget {
  @override
  _RecommendedState createState() => _RecommendedState();
}

class _RecommendedState extends State<Recommended> {
  Channel _channel;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _initChannel();
    getData();
  }

  _initChannel() async {
    Channel channel = await APIService.instance.fetchChannel(
        channelId:
            'UCtx2V8wUF4YXWPbrNL3ZsCA'); //Change the channel name here.. In the channel link the last part is the channel id
    setState(() {
      _channel = channel;
    });
  }

  _buildVideo(Video video) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white,
                width: 1,
              )),
          height: MediaQuery.of(context).size.height / 3.65,
          width: MediaQuery.of(context).size.width / 1.5,
          child: GridTile(
            child: Stack(children: [
              Image(
                image: NetworkImage(video.thumbnailUrl),
                fit: BoxFit.cover,
              ),
              Positioned(
                top: MediaQuery.of(context).size.width / 7.5,
                left: MediaQuery.of(context).size.width / 4,
                child: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.youtube,
                    color: Colors.white,
                    size: 55,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => VideoScreen(id: video.id),
                      ),
                    );
                  },
                ),
              )
            ]),
            footer: GridTileBar(
              backgroundColor: Colors.white,
              title: Text(
                video.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontFamily: "Gilroy",
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getData() async {
    _auth.onAuthStateChanged.listen((user) async {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: (_channel == null)
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).padding.top / 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, bottom: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Recommended',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontFamily: "Gilroy",
                              fontSize: 25.0,
                            )),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 20, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Try out these items for your menu',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Gilroy",
                              fontSize: 15.0,
                            )),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20.0, top: 10, bottom: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Recipes',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w900,
                              fontFamily: "Gilroy",
                              fontSize: 22.0,
                            )),
                      ),
                    ),
                    Container(
                      //color: Colors.redAccent,
                      height: MediaQuery.of(context).size.height / 3.2,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _channel.videos.length,
                        itemBuilder: (BuildContext context, int index) {
                          Video video = _channel.videos[index];
                          return _buildVideo(video);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 10, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Get Materials',
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w900,
                              fontFamily: "Gilroy",
                              fontSize: 25.0,
                            )),
                      ),
                    ),
                    Container(
                      //color: Colors.white,
                      height: MediaQuery.of(context).size.height / 3,
                      child: StreamBuilder(
                          stream: Firestore.instance
                              .collection('homemakers')
                              .document('fCFcQHflopXZKD3JjNcFziS1lHr1')
                              .snapshots(),
                          builder: (context, snapshot) {
                            return ListView.builder(
                                itemCount: 1, //Make it dynamic
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Card(
                                      color: Colors.white,
                                      elevation: 3,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    'https://firebasestorage.googleapis.com/v0/b/naniz-team.appspot.com/o/image_picker7100158006579951317.jpg?alt=media&token=5e429e62-2b2c-4225-8471-e1b27972bdaf'),
                                                radius: 30,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                      'Paneer',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w900),
                                                    ),
                                                    Text(
                                                      'Amul Dairy',
                                                      style: TextStyle(
                                                          color: Colors.black54,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    Text(
                                                      '₹50 / 250g',
                                                      style: TextStyle(
                                                          color: Colors.black54,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      5),
                                              MaterialButton(
                                                  color: Colors.redAccent,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      side: BorderSide(
                                                        color:
                                                            Color(0xffFE506D),
                                                      )),
                                                  child: Text('Get',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontFamily: "Gilroy",
                                                        fontSize: 18.0,
                                                      )),
                                                  onPressed: () {}),
                                            ]),
                                      ),
                                    ),
                                  );
                                });
                          }),
                    ),
                  ],
                ),
              ));
  }
}

class VideoScreen extends StatefulWidget {
  final String id;

  VideoScreen({this.id});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.id,
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      appBar: AppBar(
        backgroundColor: Colors.black54,
      ),
      body: Center(
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          onReady: () {
            print('Player is ready.');
          },
        ),
      ),
    );
  }
}
