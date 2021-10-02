import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homework/common/constants.dart';
import 'package:homework/model/video_to.dart';
import 'package:homework/widget/video_player.dart';

class FloatingVideoPlayer extends StatefulWidget{
  final VoidCallback onClose;
  FloatingVideoPlayer({this.onClose,Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => FloatingVideoPlayerState();
}

class FloatingVideoPlayerState extends State<FloatingVideoPlayer>{
  VideoTo _video;
  GlobalKey<VideoPlayerWidgetState> _player = new GlobalKey();

  setVideo(VideoTo video){
    if(_video != null && video == null){
      // _player.currentState?.release();
      _player.currentState?.markReleaseOnDispose();
      // _player.currentState?.release(forcePause: true);
    }
    setState(() {
      _video = video;
      if(_video != null) _player.currentState?.reset(_video.url);
    });
  }

  play(){
    _player.currentState?.doPlay(debugLabel: 'FloatingVideoPlayerState play',forcePlay: true);
  }

  pause(){
    _player.currentState?.doPause();
  }

  @override
  Widget build(BuildContext context) {
    if(_video == null) return Container();
    return new Container(
      color: kWindowBackground,
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          VideoPlayerWidget(
            _video.url,
            thumb: _video.cover,
            autoPlay: false,
            enable: false,
            key: _player,
            showProgress: true,
            onPlayerStateChange: (state) {
              WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
            },
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_video.title,maxLines: 2,overflow: TextOverflow.ellipsis,style: TextStyle(color: kContentTitleTextColor,fontSize: kContentTitleTextSize),),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(_video.desc,maxLines: 1,overflow: TextOverflow.ellipsis,style: TextStyle(color: kContentDescTextColor,fontSize: kContentTitleTextSize),),
                  )
                ],
              ),
            )
          ),
          if(_player.currentState != null)
            IconButton(
              icon: Icon((_player.currentState.isPlaying() ?? true) ? Icons.pause : Icons.play_arrow),
              onPressed: (){
                // maybe null
                // bool isPlaying = _player.currentState?.isPlaying();
                // setState(() {
                  _player.currentState?.doPlay(debugLabel: 'play from floating video player');
                  // if(isPlaying == true){
                  //   _player.currentState?.doPause();
                  // }else if(isPlaying == false){
                  //   _player.currentState?.doPlay(debugLabel: 'play from floating video player');
                  // }
                // });
              }
            ),
          if(_player.currentState == null)
            Padding(
              padding: EdgeInsets.all(8),
              child: CupertinoActivityIndicator(radius: 12,),
            ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: (){
              setVideo(null);
              widget.onClose?.call();
            }
          )
        ],
      ),
    );
  }
}