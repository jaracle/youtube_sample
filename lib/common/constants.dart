import 'package:flutter/cupertino.dart';

const bool kDebug = true;
const List<String> kTestImage = [
  'https://img1.baidu.com/it/u=2157556946,824006828&fm=26&fmt=auto',
  'https://test-videos.co.uk/user/pages/images/big_buck_bunny.jpg',
  'https://test-videos.co.uk/user/pages/images/jellyfish.jpg',
];
const List<String> kTestVideo = [
  'https://media.w3.org/2010/05/sintel/trailer.mp4',
  'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/720/Big_Buck_Bunny_720_10s_1MB.mp4',
  'https://test-videos.co.uk/vids/jellyfish/mp4/h264/720/Jellyfish_720_10s_1MB.mp4',
];
const double kGlobalPadding = 12;
const double kContentTitleTextSize = 14;
const Color kContentTitleTextColor = Color(0xFF333333);
const double kContentDescTextSize = 11;
const Color kContentDescTextColor = Color(0xFF666666);
const Color kWindowBackground = Color(0xFFF2F2F2);

class StatusCode{
  static const int notLikeOrDislike = 0;
  static const int liked = 1;
  static const int disliked = 2;
}