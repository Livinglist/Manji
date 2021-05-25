import 'package:flutter/material.dart';

class KanjiStudyHelpPage extends StatefulWidget {
  @override
  _KanjiStudyHelpPageState createState() => _KanjiStudyHelpPageState();
}

class _KanjiStudyHelpPageState extends State<KanjiStudyHelpPage> {
  final scrollController = ScrollController();
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
        appBar: AppBar(elevation: showShadow ? 8 : 0),
        backgroundColor: Theme.of(context).primaryColor,
        body: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                    'Tap on the card to reveal more information about the kanji.',
                    style: TextStyle(color: Colors.white)),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                    'Tip: You can double tap on the card to check out detailed information about the kanji.',
                    style: TextStyle(color: Colors.white)),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                    'Swipe right if you want to keep studying the current card.',
                    style: TextStyle(color: Colors.white)),
              ),
              Material(
                elevation: 8,
                child: Container(
                  child: Image.asset('data/right.png', width: 240),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                    'Swipe left if you have memorized the current card. (This card will then be removed from the deck)',
                    style: TextStyle(color: Colors.white)),
              ),
              Material(
                elevation: 8,
                child: Container(
                  child: Image.asset('data/left.png', width: 240),
                ),
              ),
              const SizedBox(height: 48, width: double.infinity)
            ],
          ),
        ));
  }
}
