import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../models/kanji.dart';

class RadicalsPage extends StatefulWidget {
  final List<String> selectedRadicals;

  RadicalsPage({@required this.selectedRadicals});

  @override
  _RadicalsPageState createState() => _RadicalsPageState();
}

class _RadicalsPageState extends State<RadicalsPage> {
  final scrollController = ScrollController();
  final Map<String, bool> radicalsMap = {};
  bool showShadow = false, shouldVibrate = false, showMeanings = false;

  @override
  void initState() {
    radicalsMap.addAll(radicalsToMeaning.map((key, value) => MapEntry(key, false)));

    for (var selected in widget.selectedRadicals) {
      radicalsMap[selected] = true;
    }

    scrollController.addListener(() {
      if (this.mounted) {
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

    Vibration.hasCustomVibrationsSupport().then((hasCoreHaptics) {
      setState(() {
        shouldVibrate = hasCoreHaptics;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(radicalsMap),
              ),
              title: Text('Radicals'),
              elevation: showShadow ? 8 : 0,
            ),
            body: ListView(
              controller: scrollController,
              shrinkWrap: true,
              addAutomaticKeepAlives: true,
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 4),
                    child: Row(
                      children: [
                        ActionChip(
                          label: Text(
                            'Clear',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.orange,
                          onPressed: () {
                            setState(() {
                              radicalsMap.updateAll((key, value) => radicalsMap[key] = false);
                            });

                            if (shouldVibrate) {
                              Vibration.cancel().then((_) {
                                Vibration.vibrate(pattern: [0, 5], intensities: [200]);
                              });
                            }
                          },
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        ActionChip(
                          label: Text(
                            showMeanings ? 'Hide meanings' : 'Show meanings',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.orange,
                          onPressed: () {
                            setState(() {
                              showMeanings = !showMeanings;
                            });

                            if (shouldVibrate) {
                              Vibration.cancel().then((_) {
                                Vibration.vibrate(pattern: [0, 5], intensities: [200]);
                              });
                            }
                          },
                        ),
                      ],
                    )),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Divider(height: 0),
                ),
                ...buildChildren()
              ],
            )),
        onWillPop: () => Future.value(false));
  }

  List<Widget> buildChildren() {
    final children = <Widget>[];
    final dividerColor = Theme.of(context).primaryColor == Colors.black ? Colors.white38 : Colors.black12;

    for (final stroke in strokesToRadicals.keys.toList()..sort()) {
      var strokeText = '$stroke strokes';

      if (stroke == 1) strokeText = strokeText.substring(0, strokeText.length - 1);

      final wrap = Padding(
        padding: EdgeInsets.only(left: 8, bottom: 4),
        child: Wrap(
          key: ObjectKey(strokeText),
          alignment: WrapAlignment.start,
          spacing: 8,
          children: <Widget>[
            Chip(
              label: Text(
                strokeText,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.grey[600],
            ),
            for (var r in strokesToRadicals[stroke])
              FilterChip(
                  selected: radicalsMap[r],
                  elevation: radicalsMap[r] ? 4 : 0,
                  label: Text(showMeanings ? r + " | ${radicalsToMeaning[r]}" : r),
                  onSelected: (val) {
                    setState(() {
                      radicalsMap[r] = !radicalsMap[r];
                    });

                    if (shouldVibrate) {
                      Vibration.cancel().then((_) {
                        Vibration.vibrate(pattern: [0, 5], intensities: [200]);
                      });
                    }
                  }),
          ],
        ),
      );

      children.add(wrap);

      children.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Divider(height: 0, color: dividerColor),
      ));
    }

    children.removeLast();

    children.add(SizedBox(height: 128));

    return children;
  }
}
