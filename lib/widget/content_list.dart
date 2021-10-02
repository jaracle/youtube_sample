import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:homework/common/constants.dart';
import 'package:homework/common/logger.dart';

typedef Future<List<T>> ContentFetcher<T>(int page, int size);
typedef Widget ContentBuilder<T>(BuildContext context, int index,T item);

enum ListState{
  initializing,
  refreshing,
  loadingMore,
  noData,
  noMore,
  idle
}

class ContentList<T> extends StatefulWidget{
  final ContentFetcher<T> fetcher;
  final ContentBuilder<T> builder;

  ContentList(this.fetcher,this.builder,{Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ContentListState<T>();
}

class ContentListState<T> extends State<ContentList<T>>{
  static const int kInitialPage = 1;
  static const int kPageSize = 10;
  final ScrollController _scrollController = new ScrollController();
  List<T> _contents;
  int _page = kInitialPage;
  ListState _state = ListState.initializing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollEndNotification) {
      if (_scrollController.position.extentAfter == 0 && _state != ListState.noMore) {
        _loadMore();
      }
    }
    return false;
  }

  replace(int index,T item){
    if (index != -1 && index <= _contents.length - 1) {
      _contents[index] = item;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _reload() async{
    _page = kInitialPage;
    setState(() {
      _state = ListState.refreshing;
    });
    await _load();
  }

  _loadMore(){
    _page ++;
    setState(() {
      _state = ListState.loadingMore;
      _load();
    });
  }

  Future<void> _load() {
    Completer completer = new Completer();
    widget.fetcher(_page,kPageSize).then((result) {
      if (_contents == null) _contents = [];
      if (_page == kInitialPage) {
        _contents.clear();
      }
      _contents.addAll(result);
      if (mounted) {
        setState(() {
          _state = (result == null || result.length == 0)
              ? _page == kInitialPage ? ListState.noData : ListState.noMore
              : ListState.idle;
        });
      }
      completer.complete();
    }).catchError((e) {
      logger(e.toString());
      completer.complete();
      if (mounted) {
        setState(() {
          _state = ListState.idle;
        });
      }
    });
    return completer.future;
  }

  _noDataTip() {
    return new Center(
      child: Text(
        '暂无相关内容',
        style: TextStyle(
          color: Colors.black.withOpacity(0.24),
          fontSize: 16
        ),
      ),
    );
  }

  _noMoreTip() {
    return new Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: kGlobalPadding),
        child: Text(
          '已经到底啦~',
          style: TextStyle(
              color: Colors.black.withOpacity(0.24),
              fontSize: 16
          ),
        ),
      ),
    );
  }

  _initializingTip() {
    return new Center(
      child: Text(
        '加载中',
        style: TextStyle(
          color: Colors.black.withOpacity(0.24),
          fontSize: 16
        ),
      ),
    );
  }

  _loadingTip(){
    return new Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: kGlobalPadding),
        child: CupertinoActivityIndicator(radius: 12,),
      ),
    );
  }

  Widget _buildItem(int index){
    List<Widget> children = [];
    children.add(widget.builder(context,index,_contents[index]));
    if(index == _contents.length - 1) {
      if(_state == ListState.loadingMore){
        children.add(_loadingTip());
      }else if(_state == ListState.noMore){
        children.add(_noMoreTip());
      }
    }
    return children.length == 1
      ? children[0]
      : Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    if(_state == ListState.initializing){
      return _initializingTip();
    }else if(_state == ListState.noData){
      return _noDataTip();
    }
    return new RefreshIndicator(
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _contents.length,
          itemBuilder: (ctx,index) => _buildItem(index)
        ),
      ),
      onRefresh: _reload
    );
  }
}