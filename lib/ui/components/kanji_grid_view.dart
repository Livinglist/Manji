import 'package:flutter/material.dart';
import 'package:flutter_device_type/flutter_device_type.dart';

import '../../bloc/settings_bloc.dart';
import '../../models/kanji.dart';
import '../kanji_detail_page/kanji_detail_page.dart';

typedef StringCallback = void Function(String str);

class KanjiGridView extends StatelessWidget {
  final List<Kanji> kanjis;
  final String fallBackFont;
  final StringCallback onLongPressed;
  final bool canRemove;
  final ScrollController scrollController;
  final ScrollPhysics scrollPhysics;

  KanjiGridView(
      {this.kanjis,
      this.fallBackFont,
      this.onLongPressed,
      this.canRemove = false,
      this.scrollController,
      this.scrollPhysics = const AlwaysScrollableScrollPhysics()})
      : assert(kanjis != null);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return GridView.count(
      controller: scrollController,
      shrinkWrap: true,
      crossAxisCount: Device.get().isTablet ? (width < 505 ? 5 : 10) : 5,
      physics: scrollPhysics,
      children: List.generate(
        kanjis.length,
        (index) {
          final kanji = kanjis[index];
          return Center(
            child: InkWell(
              child: Container(
                width: MediaQuery.of(context).size.width / 5,
                height: MediaQuery.of(context).size.width / 5,
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Hero(
                        tag: kanji.kanji,
                        child: Material(
                          color: Colors.transparent,
                          child: StreamBuilder(
                            key: ObjectKey(kanji.kanji),
                            stream: SettingsBloc.instance.fontSelection,
                            initialData:
                                SettingsBloc.instance.tempFontSelection,
                            builder: (_, snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                  kanji.kanji,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontFamily: snapshot.data ==
                                            FontSelection.handwriting
                                        ? Fonts.kazei
                                        : Fonts.ming,
                                  ),
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Text(
                        (index + 1).toString(),
                        style:
                            const TextStyle(fontSize: 8, color: Colors.white24),
                      ),
                    )
                  ],
                ),
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => KanjiDetailPage(kanji: kanji)));
              },
              onLongPress: () {
                if (onLongPressed != null) {
                  onLongPressed(kanjis[index].kanji);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
