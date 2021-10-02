
import 'package:homework/common/constants.dart';

class VideoTo{
  final String cover;
  final String url;
  final String title;
  final String desc;
  int _likeStatus;
  int likeCount;
  int dislikeCount;

  VideoTo({this.cover, this.url, this.title, this.desc,
    int likeStatus = StatusCode.notLikeOrDislike,
    this.likeCount,this.dislikeCount}) {
    _likeStatus = likeStatus;
  }

  int get likeStatus => _likeStatus;

  set likeStatus(int value) {
    if(value == _likeStatus) return;
    if(value == StatusCode.notLikeOrDislike){
      if(_likeStatus == StatusCode.liked) {
        likeCount --;
      }else if(_likeStatus == StatusCode.disliked){
        dislikeCount --;
      }
    }else if(value == StatusCode.liked){
      if(_likeStatus == StatusCode.notLikeOrDislike) {
        likeCount ++;
      }else if(_likeStatus == StatusCode.disliked){
        likeCount ++;
        dislikeCount --;
      }
    }else if(value == StatusCode.disliked){
      if(_likeStatus == StatusCode.notLikeOrDislike) {
        dislikeCount ++;
      }else if(_likeStatus == StatusCode.liked){
        likeCount --;
        dislikeCount ++;
      }
    }
    _likeStatus = value;
  }
}