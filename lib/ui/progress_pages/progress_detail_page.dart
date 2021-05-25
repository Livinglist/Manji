import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../bloc/kanji_bloc.dart';
import '../../bloc/kanji_list_bloc.dart';
import 'components/kanji_progress_list_tile.dart';

///This is the page that displays lists created by users
class ProgressDetailPage extends StatefulWidget {
  final List<Kanji> kanjis;
  final String title;
  final int totalStudied;

  ProgressDetailPage({this.kanjis, this.title = '', int totalStudied})
      : assert(kanjis != null),
        totalStudied = totalStudied ??
            kanjis.where((kanji) => kanji.timeStamps.isNotEmpty).length {
    kanjis.sort((a, b) => b.timeStamps.length.compareTo(a.timeStamps.length));
  }

  @override
  _ProgressDetailPageState createState() => _ProgressDetailPageState();
}

class _ProgressDetailPageState extends State<ProgressDetailPage> {
  final scrollController = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final textEditingController = TextEditingController();
  bool showShadow = false;

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if (mounted) {
        if (scrollController.offset <= 0) {
          setState(() {
            showShadow = false;
          });
        } else if (showShadow == false) {
          setState(() {
            showShadow = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
            elevation: showShadow ? 8 : 0,
            title: Text(widget.title),
            actions: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(12),
                  child: Center(
                      child: Text(
                          '${widget.totalStudied}/${widget.kanjis.length}',
                          style: const TextStyle(fontSize: 18))))
            ]),
        body: ListView.separated(
            controller: scrollController,
            itemBuilder: (_, index) {
              return KanjiProgressListTile(
                  kanji: widget.kanjis.elementAt(index));
            },
            separatorBuilder: (_, index) => const Divider(height: 0),
            itemCount: widget.kanjis.length));
  }
}
