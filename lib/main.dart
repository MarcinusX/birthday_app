import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

void main() {
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(new MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Happy birthday Asia!',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
        canvasColor: Colors.yellow[300],
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController windAnimationController;
  AnimationController wishCardAnimationController;
  final VideoPlayerController videoPlayerController =
      VideoPlayerController.asset('assets/video.mp4');
  Animation windAnimation;
  GlobalKey<_LungsState> lungsKey = new GlobalKey<_LungsState>();

  List<String> wishes = [
    'I wish you all the luck ...',
    '... to smile whenever you can ...',
    '... to fulfill your dreams ...',
    '... to be surrounded by the people who love you ...',
    '... to have great contact with mom, dad and Noah ...',
    '... to become the greatest drummer ever ...',
    '... to have awesome friends you can count on ...',
    '... to dream big and never back down ...',
    '... and to all your wishes came true.',
    'HAPPY BIRTHDAY!!!'
  ];

  List<double> percentageDrops = [
    0.0005,
    0.001,
    0.002,
    0.005,
    0.01,
    0.015,
    0.02,
    0.025,
    0.03,
    0.04
  ];

  int level = 0;

  @override
  void initState() {
    super.initState();
    windAnimationController = new AnimationController(
        vsync: this, duration: Duration(milliseconds: 500));
    windAnimation = Tween(begin: 100.0, end: 0.0).animate(CurvedAnimation(
      parent: windAnimationController,
      curve: Curves.easeOut,
    ));
    windAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 300), () {
          wishCardAnimationController.forward();
        });
        if (level == 9) {
          Future.delayed(Duration(milliseconds: 1000), () {
            videoPlayerController
                .initialize()
                .then((_) => videoPlayerController.play());
          });
        }
      }
    });
    wishCardAnimationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    windAnimationController.dispose();
    wishCardAnimationController.dispose();
    videoPlayerController.pause();
    videoPlayerController.dispose();
    super.dispose();
  }

  void _onInhaled() {
    windAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: SafeArea(
        child: level < 10
            ? Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: windAnimationController,
                      builder: (context, child) => Column(
                            children: <Widget>[
                              Expanded(
                                child: Stack(
                                  alignment: Alignment.topCenter,
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/candle.jpg',
                                      height: 200.0,
                                      width: 200.0,
                                    ),
                                    Opacity(
                                      opacity: windAnimationController.value,
                                      child: Container(
                                        color: Theme.of(context).canvasColor,
                                        height: 20.0,
                                        width: 20.0,
                                      ),
                                    ),
                                  ]..addAll(List.generate(
                                      10,
                                      (i) => LevelStar(
                                            level: level,
                                            starLevel: i,
                                          ))),
                                ),
                              ),
                              Transform.translate(
                                offset: Offset(0.0, windAnimation.value),
                                child: windAnimationController.isDismissed
                                    ? Container()
                                    : WindBlow(),
                              ),
                              windAnimationController.isDismissed
                                  ? Text("Tap quickly to inhale!")
                                  : Container(),
                              Lungs(
                                onInhaled: _onInhaled,
                                key: lungsKey,
                                percentageDrop: percentageDrops[level],
                              ),
                            ],
                          ),
                    ),
                    WishCard(
                      wishCardAnimationController,
                      text: wishes[level],
                      onClick: _onCardDismissed,
                      showVideo: level == 9,
                      videoPlayerController: videoPlayerController,
                    ),
                  ],
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 100.0,
                    ),
                    Text(
                      "Happy Birthday Asia!!!",
                      style: Theme.of(context).textTheme.display1,
                    ),
                    Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 100.0,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _onCardDismissed() {
    setState(() {
      level++;
    });
    wishCardAnimationController.reset();
    windAnimationController.reset();
    lungsKey.currentState.reset();
  }
}

class LevelStar extends StatelessWidget {
  final int level;
  final int starLevel;

  const LevelStar({Key key, this.level, this.starLevel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: (starLevel % 5) * 40.0,
      left: starLevel < 5 ? 0.0 : null,
      right: starLevel < 5 ? null : 0.0,
      child: Icon(
        level > starLevel ? Icons.star : Icons.star_border,
        color: Colors.yellow[700],
      ),
    );
  }
}

class WishCard extends AnimatedWidget {
  final String text;
  final VoidCallback onClick;
  final bool showVideo;
  final VideoPlayerController videoPlayerController;

  WishCard(animation,
      {this.text, this.onClick, this.showVideo, this.videoPlayerController})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    Animation<double> animation = listenable;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scale(animation.value)
        ..rotateX(math.pi * 4 * animation.value),
      child: GestureDetector(
        onTap: onClick,
        child: Card(
          elevation: 10.0,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.lightGreenAccent,
                border: Border.all(color: Colors.blue, width: 2.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(text, textAlign: TextAlign.center,),
                  showVideo
                      ? Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                            height: 400.0,
                            child: VideoPlayer(videoPlayerController)),
                      )
                      : Container()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WindBlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -math.pi / 2,
      child: SvgPicture.asset(
        'assets/wind.svg',
        width: 80.0,
        height: 80.0,
        color: Colors.lightBlueAccent,
      ),
    );
  }
}

class Lungs extends StatefulWidget {
  final double percentageDrop;
  final VoidCallback onInhaled;

  const Lungs({Key key, this.percentageDrop = 0.01, this.onInhaled})
      : super(key: key);

  @override
  _LungsState createState() => _LungsState();
}

class _LungsState extends State<Lungs> {
  reset() {
    setState(() => _percentage = 0.2);
    _initTimer();
  }

  double _percentage = 0.2;
  Timer timer;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _initTimer() {
    timer = new Timer.periodic(Duration(milliseconds: 100), (Timer t) {
      setState(() {
        _percentage -= widget.percentageDrop;
        if (_percentage < 0.0) {
          _percentage = 0.0;
        }
      });
    });
  }

  void _onTap() {
    setState(() {
      _percentage += 0.1;
      if (_percentage >= 1.0) {
        widget.onInhaled();
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Transform(
                  transform: Matrix4.identity()
                    ..rotateY(math.pi)
                    ..translate(-125.0),
                  child: LungFill(percentage: _percentage)),
              LungFill(percentage: _percentage),
            ],
          ),
          SvgPicture.asset(
            'assets/lungs.svg',
            height: 250.0,
            width: 250.0,
          ),
        ],
      ),
    );
  }
}

class LungFill extends StatelessWidget {
  final double percentage;

  const LungFill({Key key, this.percentage = 0.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: LungsClipper(),
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
        child: Container(
          height: 250.0 - 80.0,
          width: 125.0,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: ((1.0 - percentage) * 1000).toInt(),
                child: Container(
                  color: Colors.white,
                  width: 125.0,
                ),
              ),
              Expanded(
                flex: (percentage * 1000).toInt(),
                child: Container(
                  color: Color.fromARGB(255, 220, 240, 245),
                  width: 125.0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LungsClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(40.0, 58.0);
    path.arcToPoint(Offset(110.0, 230.0),
        radius: Radius.elliptical(70.0, 115.0));
    path.lineTo(30.0, 210.0);
    path.lineTo(25.0, 120.0);
    path.lineTo(36.0, 90.0);
    path.lineTo(32.0, 62.0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
