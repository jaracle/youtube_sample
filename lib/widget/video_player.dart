import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:connectivity/connectivity.dart';
import 'package:homework/common/memory_cache.dart';
import 'package:homework/util/string_util.dart';
import 'alert_message_dialog.dart';
import 'package:orientation/orientation.dart';
import 'package:flutter/cupertino.dart';
import 'package:homework/common/logger.dart';

typedef bool CheckPermission();

class VideoPlayerWidget extends StatefulWidget{
  final String video;
  final bool isLocal;
  final bool isAssets;
  final String thumb;
  final bool autoPlay;
  final bool enable;
  final bool showMaximize;
  final bool autoLoad;
  final bool showProgress;
  final ValueSetter<VideoPlayerValue> onPlayerStateChange;

  VideoPlayerWidget(this.video,{this.isLocal = false,this.isAssets = false,
    this.thumb,this.autoPlay = true,
    this.enable = true,this.showMaximize = false,
    Key key,this.autoLoad = false,this.onPlayerStateChange,
    this.showProgress = false}):super(key:key);

  @override
  State<StatefulWidget> createState() {
    return new VideoPlayerWidgetState();
  }
}

class VideoRef{
  VideoPlayerController controller;
  bool isDisposed;

  VideoRef({this.controller,this.isDisposed = false});
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> with WidgetsBindingObserver{
  static VideoRef _videoRef = new VideoRef();
  String _video;
  VideoPlayerController _controller;
  bool _showControls = false;
  double _position = 0;
  Timer _timer;
  Timer _autoHider;
  bool _isLoading = false;
  bool _shouldReleaseOnDispose = false;

  @override
  void initState(){
    super.initState();
    _video = widget.video;
    if(widget.autoPlay){
      _loadVideo();
    }else if(widget.autoLoad){
      _init();
    }
  }

  reset(String video){
    _video = video;
    logger('VideoPlayer reset video:$_video');
    _controller?.removeListener(_onPlayerStateChange);
    _cleanTimer();
    setState(() {
      _controller = null;
    });
  }

  markReleaseOnDispose(){
    _shouldReleaseOnDispose = true;
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.inactive
      || state == AppLifecycleState.paused){
      doPause();
    }
  }

  @override
  void deactivate(){
    super.deactivate();
    // logger('VideoPlayer deactivate,video:${widget.video}');
    // doPause();
  }

  // load the video and play it automatically
  _loadVideo(){
    if(_isLoading) return;
    _isLoading = true;
    if(mounted){
      setState(() {

      });
    }
    logger('_loadVideo');
    _doLoad();
    logger('_controller:${_controller?.dataSource}');
    if(_controller.value.isInitialized){
      logger('initialized');
      if(_controller.value.isPlaying) {
        logger('prePause');
        _controller.pause();
      }
      doPlay(debugLabel: '_loadVideo,initialized');
    }else{
      logger('!initialized');
      _controller.initialize().then((_){
        doPlay(debugLabel: '_loadVideo,new');
        if(mounted){
          setState(() {

          });
        }
      });
    }
  }

  _doLoad(){
    //check whether cached or not
    if(_videoRef.controller?.dataSource == _video && !_videoRef.isDisposed){
      _controller = _videoRef.controller;
    }else{
      _controller = widget.isLocal ?
      widget.isAssets ? VideoPlayerController.asset(_video) : VideoPlayerController.file(new File(_video))
          : VideoPlayerController.network(_video);
      _controller.setLooping(false);
      _videoRef.controller = _controller;
      _videoRef.isDisposed = false;
    }
    _controller.addListener(_onPlayerStateChange);
  }

  _onPlayerStateChange(){
    widget.onPlayerStateChange?.call(_controller.value);
  }

  _init(){
    if(_controller == null || !_controller.value.isInitialized){
      _doLoad();
    }
    if(!_controller.value.isInitialized){
      _controller.initialize().then((_){
        if(mounted){
          setState(() {

          });
        }
      });
    }
  }

  _updatePosition(timer){
    logger('_updatePosition,pos:${_controller.value.position},duration:${_controller.value.duration}');
    double pos = _controller.value.position.inSeconds/_controller.value.duration.inSeconds;
    if(mounted){
      setState(() {
        _position = pos;
      });
    }
  }

  // play or pause video
  doPlay({String debugLabel,bool forcePlay = false}) async{
    logger('_doPlay from $debugLabel');
    if(_controller == null || !_controller.value.isInitialized){
      _loadVideo();
      return;
    }
    _isLoading = false;
    if(MemoryCache.shouldWarnWifi){
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        bool result = await showDialog(context: context,builder: (context){
          return new AlertMessageDialog('当前使用的是非WiFi网络\n播放可能会产生流量费用',showCancel: true,button: '仍然播放',);
        });
        if(result != true) return;
        MemoryCache.shouldWarnWifi = false;
      }
    }

    setState(() {
      if(_autoHider != null){
        _autoHider.cancel();
      }
      if(_controller.value.isPlaying){
        if(!forcePlay){
          doPause();
        }
      }else{
        logger('doPlay,video:${widget.video}');
        _autoHider = Timer.periodic(new Duration(seconds: 5), (t){
          if(mounted){
            setState(() {
              _showControls = false;
            });
          }
        });
        _controller.play();
        //检查是否被暂停了，是的话重启播放
        Timer(Duration(milliseconds: 500), (){
          if(!_controller.value.isPlaying && !_videoRef.isDisposed) _controller.play();
        });
        if(_timer == null){
          _timer = Timer.periodic(new Duration(seconds: 1), _updatePosition);
        }
      }
    });
  }

  _cleanTimer(){
    _timer?.cancel();
    _autoHider?.cancel();
  }

  void release({bool forcePause = false}){
    _videoRef.controller = null;
    _videoRef.isDisposed = true;
    // if(!widget.enable){
    //   _controller?.dispose();
    //   return;
    // }
    if(forcePause){
      _controller?.pause();
    }
    _controller?.removeListener(_onPlayerStateChange);
    _controller?.dispose();
    _cleanTimer();
    logger('release,forcePause:$forcePause');
  }

  bool isPlaying(){
    return _controller?.value?.isPlaying;
  }

  void doPause(){
    logger('doPause');
    _controller?.pause();
  }

  @override
  void dispose() {
    super.dispose();
    logger('VideoPlayer dispose,video:${widget.video}');
    if(_shouldReleaseOnDispose){
      release(forcePause: true);
    }else{
      _cleanTimer();
    }
  }

  Widget _controls(){
    String currTimeStr = StringUtil.parseTime(_controller.value.position.inSeconds);
    String totalTimeStr = StringUtil.parseTime(_controller.value.duration.inSeconds);
    return new Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6)
              ),
              child: Slider(
                  value: _position,
                  activeColor: Colors.red,
                  inactiveColor: Colors.red.withOpacity(0.4),
                  onChanged: (pos){
                    int newPosInSec =  (_controller.value.duration.inSeconds*pos).toInt();
                    _controller.seekTo(Duration(seconds:newPosInSec));
                  }
              )
            )
          ),
          Padding(
            padding: EdgeInsets.only(left: 10,right: widget.showMaximize ? 0 : 10),
            child: Text('$currTimeStr/$totalTimeStr',style: TextStyle(color: Colors.white,fontSize: 10),),
          ),
          if(widget.showMaximize)
            InkWell(
              child: Padding(
                padding: EdgeInsets.only(left: 10,top: 6,right: 10,bottom: 6),
                child: Icon(Icons.crop_free,color: Colors.white,),
              ),
              onTap: (){
                if(MediaQuery.of(context).orientation == Orientation.portrait){
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight,
                  ]);
                  OrientationPlugin.forceOrientation(DeviceOrientation.landscapeRight);
                }else{
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitDown,
                    DeviceOrientation.portraitUp,
                  ]);
                  OrientationPlugin.forceOrientation(DeviceOrientation.portraitUp);
                }
              },
            )
        ],
      ),
    );
  }

  Widget _mask(){
    return Positioned.fill(
        child: Container(
          color: Colors.black12,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return _controller != null && !_videoRef.isDisposed && _controller.value.isInitialized ?
      new AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: InkWell(
                child: VideoPlayer(_controller),
                onTap: widget.enable ? (){
                  if(_autoHider == null){
                    doPlay(debugLabel: 'first tap');
                  }else{
                    setState(() {
                      _showControls = !_showControls;
                    });
                  }
                } : null,
              )
            ),
            if(widget.enable && _showControls)
              _mask(),
            if(widget.enable && _showControls)
              _controls(),
            if(widget.enable && _showControls)
              Align(
                alignment: Alignment.center,
                child: IconButton(
                  icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow,color: Colors.white,size: 48,),
                  onPressed: () => doPlay(debugLabel: 'play button')
                ),
              ),
            if(widget.enable && _showControls)
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_down,color: Colors.white,size: 32,),
                  onPressed: () => Navigator.pop(context)
                ),
              ),
            if(widget.showProgress)
              Positioned(
                left: 0,
                bottom: 0,
                right: 0,
                child: FractionallySizedBox(
                  widthFactor: _position,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 2,
                    width: double.infinity,
                    color: Colors.red,
                  ),
                )
              )
          ],
        ),
      )
    : AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        width: double.infinity,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
                child: (widget.thumb != null && widget.thumb.isNotEmpty)
                    ? InkWell(
                  child: Image.network(widget.thumb,fit: BoxFit.cover,),
                  onTap: widget.enable ? () => doPlay(debugLabel: 'tap cover') : null,
                ): Container()
            ),
            if(_isLoading)
              _mask(),
            if(_isLoading)
              Center(
                child: CupertinoActivityIndicator(radius: 16,),
              )
          ],
        ),
      ),
    );
  }
}