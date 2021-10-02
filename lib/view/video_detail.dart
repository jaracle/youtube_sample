import 'package:flutter/material.dart';
import 'package:homework/common/constants.dart';
import 'package:homework/model/video_to.dart';
import 'package:homework/widget/video_player.dart';

class VideoDetailPage extends StatelessWidget{
  final VideoTo item;
  VideoDetailPage(this.item);

  Widget _button(IconData icon,String text,{VoidCallback onTap}){
    return new Expanded(
        child: InkWell(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(text,style: TextStyle(color: kContentTitleTextColor,fontSize: 12),),
              )
            ],
          ),
          onTap: onTap,
        )
    );
  }

  Widget _videoInfo(){
    return new Container(
      color: Colors.white,
      padding: EdgeInsets.all(kGlobalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title,style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w600),),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text('211万次观看 · 1年前',style: TextStyle(color: kContentDescTextColor,fontSize: kContentDescTextSize)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Row(
              children: [
                _button(item.likeStatus == StatusCode.liked
                    ? Icons.thumb_up
                    : Icons.thumb_up_alt_outlined,
                    '${item.likeCount}'),
                _button(item.likeStatus == StatusCode.disliked
                    ? Icons.thumb_down
                    : Icons.thumb_down_alt_outlined,
                    '${item.dislikeCount}'),
                _button(Icons.share, '分享'),
                _button(Icons.file_download, '下载'),
                _button(Icons.save, '保存'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _userInfo(){
    return new Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.symmetric(horizontal: kGlobalPadding,vertical: 10),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple
            ),
            child: Center(
              child: Text('T',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w600),),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Test User',style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w500),),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text('50万订阅者',style: TextStyle(color: kContentDescTextColor,fontSize: kContentDescTextSize),),
                  )
                ],
              ),
            )
          ),
          Text('订阅',style: TextStyle(color: Colors.red,fontSize: 18,fontWeight: FontWeight.w500),)
        ],
      ),
    );
  }

  Widget _commentItem(String content){
    return new Padding(
      padding: EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.purple
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(content,style: TextStyle(color: kContentTitleTextColor,fontSize: 10),),
            )
          )
        ],
      ),
    );
  }

  Widget _comments(){
    List<Widget> items = List.generate(20, (index) {
      return _commentItem('测试评论测试评论测试评论测试评论测试评'
          '论测试评论测试评论测试评论测试评论测试评论测试'
          '评论测试评论测试评论测试评论测试评论测试评论$index');
    });
    return new Container(
      color: Colors.white,
      padding: EdgeInsets.all(kGlobalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('评论',style: TextStyle(color: kContentTitleTextColor,fontSize: 14),),
              Padding(
                padding: EdgeInsets.only(left: 8,top: 2),
                child: Text('100',style: TextStyle(color: kContentDescTextColor,fontSize: 14),),
              )
            ],
          )
        ]..addAll(items),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var statusBarHeight = MediaQuery.of(context).padding.top;
    return new Scaffold(
      body: Container(
        color: kWindowBackground,
        padding: EdgeInsets.only(top: statusBarHeight),
        child: Column(
          children: [
            VideoPlayerWidget(item.url,thumb: item.cover),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _videoInfo(),
                  _userInfo(),
                  _comments()
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}