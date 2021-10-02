import 'package:flutter/material.dart';
import 'package:homework/common/constants.dart';

class VideoItem extends StatelessWidget{
  final String cover;
  final String title;
  final String desc;
  final int likeStatus;
  final ValueChanged<int> onLikeListener;
  VideoItem({
    this.cover,
    this.title,
    this.desc,
    this.likeStatus = StatusCode.notLikeOrDislike,
    this.onLikeListener
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Colors.white,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(cover ?? kTestImage),
                  fit: BoxFit.cover
                )
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(kGlobalPadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title ?? '',style: TextStyle(color: kContentTitleTextColor,fontSize: kContentTitleTextSize),),
                      Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Text(desc ?? '',style: TextStyle(color: kContentDescTextColor,fontSize: kContentDescTextSize),)
                      )
                    ],
                  )
                ),
                Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: IconButton(
                    icon: Icon(likeStatus == StatusCode.liked ? Icons.thumb_up : Icons.thumb_up_alt_outlined),
                    onPressed: () => onLikeListener?.call(likeStatus == StatusCode.liked ? StatusCode.notLikeOrDislike : StatusCode.liked)
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: IconButton(
                      icon: Icon(likeStatus == StatusCode.disliked ? Icons.thumb_down : Icons.thumb_down_alt_outlined),
                      onPressed: () => onLikeListener?.call(likeStatus == StatusCode.disliked ? StatusCode.notLikeOrDislike : StatusCode.disliked)
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}