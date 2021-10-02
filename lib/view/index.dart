import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homework/common/constants.dart';
import 'package:homework/model/video_to.dart';
import 'package:homework/view/video_detail.dart';
import 'package:homework/widget/content_list.dart';
import 'package:homework/widget/video_item.dart';

class IndexPage extends StatefulWidget{
  final ValueSetter<VideoTo> onStartPlaying;
  final VoidCallback onStopPlaying;
  IndexPage({this.onStartPlaying,this.onStopPlaying});

  @override
  State<StatefulWidget> createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage>{
  GlobalKey<ContentListState> _contentList = new GlobalKey();

  Future<List<VideoTo>> _getVideoList(int page,int size) async{
    await Future.delayed(Duration(milliseconds: 200));
    return Future.value(page >= 5 ? [] : List.generate(size, (index) => VideoTo(
      cover: kTestImage[index % kTestImage.length],
      title: '测试视频$page-$index',
      url: kTestVideo[index % kTestVideo.length],
      desc: '郭德纲、陈佩斯、赵本山等觉得很赞',
      likeStatus: StatusCode.notLikeOrDislike,
      likeCount: 100,
      dislikeCount: 10
    )));
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: kWindowBackground,
      child: ContentList<VideoTo>(
        (page,pageSize) => _getVideoList(page, pageSize),
        (ctx,index,item) => InkWell(
          child: VideoItem(
              cover: item.cover,
              title: item.title,
              desc: item.desc,
              likeStatus: item.likeStatus,
              onLikeListener: (likeStatus) {
                item.likeStatus = likeStatus;
                _contentList.currentState?.replace(index, item);
              }
          ),
          onTap: () {
            widget.onStartPlaying?.call(item);
            Navigator.push(context, CupertinoPageRoute(builder: (c) => VideoDetailPage(item))).then((value) {
              widget.onStopPlaying?.call();
            });
          },
        ),
        key: _contentList,
      ),
    );
  }
}