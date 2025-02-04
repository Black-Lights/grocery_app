import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('Basic text widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Hello, Test!'),
          ),
        ),
      ),
    );

    expect(find.text('Hello, Test!'), findsOneWidget);
  });

  testWidgets('Button tap updates text', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: TestButtonWidget(),
        ),
      ),
    );

    // Initial text should be "Tap the button"
    expect(find.text('Tap the button'), findsOneWidget);

    // Tap the button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // After tap, text should change
    expect(find.text('Button Clicked!'), findsOneWidget);
  });
}

class TestButtonWidget extends StatefulWidget {
  @override
  _TestButtonWidgetState createState() => _TestButtonWidgetState();
}

class _TestButtonWidgetState extends State<TestButtonWidget> {
  String text = 'Tap the button';

  void _changeText() {
    setState(() {
      text = 'Button Clicked!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text),
        ElevatedButton(
          onPressed: _changeText,
          child: Text('Click Me'),
        ),
      ],
    );
  }
}
