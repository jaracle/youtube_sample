import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homework/common/logger.dart';
import 'package:homework/model/video_to.dart';
import 'package:homework/view/video_detail.dart';
import 'package:homework/widget/floating_video_player.dart';
import 'index.dart';

class HomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{
  static const List<IconData> _kIcons = [
    Icons.home_outlined,
    Icons.music_video,
    Icons.add_circle_outline_rounded,
    Icons.subscriptions_outlined,
    Icons.video_collection_outlined
  ];
  static const List<IconData> _kActiveIcons = [
    Icons.home,
    Icons.music_video,
    Icons.add_circle_outline_rounded,
    Icons.subscriptions,
    Icons.video_collection
  ];
  GlobalKey<FloatingVideoPlayerState> _floatingPlayer = new GlobalKey();
  VideoTo _currPlayingVideo;
  bool _showFloatingPlayer = false;
  TabController _controller;
  int _currPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = new TabController(length: 5, vsync: this);
    _controller.addListener(() {
      setState(() {
        _currPageIndex = _controller.index;
      });
    });
  }

  List<_TabModel> _buildTabs(){
    return [
      _TabModel(
        title: '首页',
        icon: _kIcons[0],
        activeIcon: _kActiveIcons[0],
        page: IndexPage(
          onStartPlaying: _onStartPlaying,
          onStopPlaying: _onStopPlaying,
        )
      ),
      _TabModel(
        title: 'Shorts',
        icon: _kIcons[1],
        activeIcon: _kActiveIcons[1],
        page: Container()
      ),
      _TabModel(
        title: '',
        icon: _kIcons[2],
        activeIcon: _kActiveIcons[2],
        page: Container()
      ),
      _TabModel(
        title: '订阅内容',
        icon: _kIcons[3],
        activeIcon: _kActiveIcons[3],
        page: Container()
      ),
      _TabModel(
        title: '媒体库',
        icon: _kIcons[4],
        activeIcon: _kActiveIcons[4],
        page: Container()
      ),
    ];
  }

  //call when video list item clicked
  _onStartPlaying(VideoTo video){
    logger('_onStartPlaying,video:${video.url}');
    _currPlayingVideo = video;
    _floatingPlayer.currentState?.setVideo(_currPlayingVideo);
  }

  //call when video detail page finished
  _onStopPlaying(){
    setState(() {
      _showFloatingPlayer = true;
      _floatingPlayer.currentState?.play();
    });
  }

  //call when floating video player clicked
  _continuePlaying(){
    _floatingPlayer.currentState?.pause();
    Navigator.push(context, PageRouteBuilder(
        pageBuilder: (c,anim,scdAnim) => VideoDetailPage(_currPlayingVideo),
        transitionsBuilder: (c,anim,scdAnim,child){
          const begin = Offset(-1, 0.5);
          const end = Offset(0,0);
          final tween = Tween(begin: begin, end: end);
          final offsetAnimation = anim.drive(tween);
          final opacityAnimation = anim.drive(Tween(begin: 0.0,end: 1.0));
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: opacityAnimation,
              child: child,
            ),
          );
        }
    )).then((value) => _onStopPlaying());
  }

  @override
  Widget build(BuildContext context) {
    var tabs = _buildTabs();
    return new Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFF8F7F7),
        unselectedItemColor: Colors.black.withOpacity(0.65),
        selectedItemColor: Colors.black,
        elevation: 4,
        unselectedFontSize: 10,
        selectedFontSize: 10,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        currentIndex: _currPageIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => _controller.animateTo(index),
        items: List.generate(tabs.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(tabs[index].icon,size: index != 2 ? 24 : 36,),
            activeIcon: Icon(tabs[index].activeIcon,size: index != 2 ? 24 : 36),
            label: tabs[index].title,
          );
        }),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: TabBarView(
              controller: _controller,
              physics: NeverScrollableScrollPhysics(),
              children: tabs.map((e) => e.page).toList(),
            )
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Offstage(
              child: InkWell(
                child: FloatingVideoPlayer(key: _floatingPlayer,onClose: (){
                  setState(() {
                    _showFloatingPlayer = false;
                  });
                },),
                onTap: _continuePlaying,
              ),
              offstage: !_showFloatingPlayer,
            ),
          )
        ],
      ),
    );
  }
}

class _TabModel{
  final String title;
  final IconData icon;
  final IconData activeIcon;
  final Widget page;

  _TabModel({this.title, this.icon, this.activeIcon,this.page});
}