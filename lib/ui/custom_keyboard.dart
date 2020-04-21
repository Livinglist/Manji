import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class Content extends StatefulWidget {
  const Content({
    Key key,
  }) : super(key: key);

  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<Content> {
  final FocusNode _customNode = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final custom1Notifier = ValueNotifier<String>("0");
  final controller = TextEditingController();

  initState() {
    super.initState();

    controller.addListener(() {
      custom1Notifier.value = controller.text;
    });

    custom1Notifier.addListener(() {
      //controller.text += custom1Notifier.value;
    });
  }

  /// Creates the [KeyboardActionsConfig] to hook up the fields
  /// and their focus nodes to our [FormKeyboardActions].
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardAction(
          focusNode: _customNode,
          toolbarButtons: [
            (node) {
              return GestureDetector(
                onTap: () => node.unfocus(),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.close),
                ),
              );
            }
          ],
          footerBuilder: (_) => CounterKeyboard(
            notifier: custom1Notifier,
          ),
        ),
        KeyboardAction(focusNode: _nodeText2, toolbarButtons: [
          (node) {
            return GestureDetector(
              onTap: () => node.unfocus(),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.close),
              ),
            );
          }
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: KeyboardActions(
        config: _buildConfig(context),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Opacity(
                  opacity: 0,
                  child: KeyboardCustomInput<String>(
                    focusNode: _customNode,
                    height: 65,
                    notifier: custom1Notifier,
                    builder: (_, __, ___) => Container(),
                  ),
                ),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  focusNode: _nodeText2,
                  decoration: InputDecoration(
                    hintText: "Input Text with Custom Done Button",
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A quick example "keyboard" widget for counter value.
class CounterKeyboard extends StatelessWidget with KeyboardCustomPanelMixin<String> implements PreferredSizeWidget {
  final ValueNotifier<String> notifier;

  CounterKeyboard({Key key, this.notifier}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(200);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                String value = notifier.value;
                value += "1";
                updateValue(value.toString());
              },
              child: FittedBox(
                child: Text(
                  "+",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
