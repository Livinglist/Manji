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
  bool showShadow = false, shouldVibrate = false;

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
            body: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 48),
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 8,
                    children: <Widget>[
                      ActionChip(
                        label: Text('Clear'),
                        onPressed: () {
                          setState(() {
                            radicalsMap.updateAll((key, value) => radicalsMap[key] = false);
                          });
                        },
                      ),
                      for (var r in radicalsMap.keys)
                        FilterChip(
                            selected: radicalsMap[r],
                            elevation: radicalsMap[r] ? 4 : 0,
                            label: Text(r),
                            onSelected: (val) {
                              if (shouldVibrate) {
                                Vibration.cancel().then((_) {
                                  Vibration.vibrate(pattern: [0, 5], intensities: [255]);
                                });
                              }

                              setState(() {
                                radicalsMap[r] = !radicalsMap[r];
                              });
                            }),
                    ],
                  ),
                ))),
        onWillPop: () => Future.value(false));
  }
}
