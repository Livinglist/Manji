import 'package:flutter/material.dart';

import 'package:kanji_dictionary/bloc/kana_bloc.dart';
import 'components/furigana_text.dart';

class KanaPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => KanaPageState();
}

class KanaPageState extends State<KanaPage> {
  //show gridview by default
  bool showGrid = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          title: FuriganaText(
            text: '仮名',
            tokens: [Token(text: '仮名', furigana: 'かな')],
            style: TextStyle(fontSize: 20),
          ),
          bottom: TabBar(tabs: [
            //Tab(child: Container(child: Text('N5'),color: Colors.black),),
            Tab(
              text: 'ひらがな',
            ),
            Tab(
              text: 'カタカナ',
            )
          ]),
        ),
        body: TabBarView(children: [
          StreamBuilder(
            stream: kanaBloc.hiragana,
            builder: (_, AsyncSnapshot<List<Hiragana>> snapshot) {
              if (snapshot.hasData) {
                var hiraganas = snapshot.data;
                return KanaGridView(kanas: hiraganas);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          StreamBuilder(
            stream: kanaBloc.katakana,
            builder: (_, AsyncSnapshot<List<Katakana>> snapshot) {
              if (snapshot.hasData) {
                var katakana = snapshot.data;
                return KanaGridView(kanas: katakana);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          )
        ]),
      ),
    );
  }
}

class KanaGridView extends StatefulWidget {
  final List<Kana> kanas;

  KanaGridView({this.kanas}) : assert(kanas != null);

  @override
  State<StatefulWidget> createState() => KanaGridViewState();
}

class KanaGridViewState extends State<KanaGridView> {
  List<Kana> kanas;
  List<CrossFadeState> crossFadeStates;

  @override
  void initState() {
    kanas = widget.kanas;
    crossFadeStates = List.generate(kanas.length, (_) => CrossFadeState.showFirst);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 5,
        children: List.generate(kanas.length, (index) {
          return Center(
              child: InkWell(
                onTap: (){
                  setState(() {
                    crossFadeStates[index] = crossFadeStates[index] == CrossFadeState.showSecond ? CrossFadeState.showFirst : CrossFadeState.showSecond;
                  });
                },
            child: GestureDetector(
              child: AnimatedCrossFade(
                  firstChild: Container(
                      width: MediaQuery.of(context).size.width / 5,
                      height: MediaQuery.of(context).size.width / 5,
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: Text(kanas[index].kana ?? '', style: TextStyle(color: Colors.white, fontSize: 36, fontFamily: 'Ai')),
                            ),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(kanas[index].pron ?? '', style: TextStyle(color: Colors.white70, fontSize: 12)))
                          ],
                        ),
                      )),
                  secondChild: Container(
                      width: MediaQuery.of(context).size.width / 5,
                      height: MediaQuery.of(context).size.width / 5,
                      child: Center(
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: Alignment.center,
                              child: Text(kanas[index].kana ?? '', style: TextStyle(color: Colors.white, fontSize: 36)),
                            ),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(kanas[index].pron ?? '', style: TextStyle(color: Colors.white70, fontSize: 12)))
                          ],
                        ),
                      )),
                  crossFadeState: crossFadeStates[index],
                  duration: Duration(milliseconds: 200)),
            ),
          ));
        }),
      ),
    );
  }
}
