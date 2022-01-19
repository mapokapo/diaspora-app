import 'package:flutter/material.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';

class SwipePage extends StatelessWidget {
  const SwipePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TinderSwapCard(
        cardBuilder: (context, index) {
          return Material(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            elevation: 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/logo.png'),
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Column(
                    children: const [
                      Text("Hello"),
                      Text("World"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        totalNum: 5,
        allowVerticalMovement: false,
        orientation: AmassOrientation.bottom,
        stackNum: 3,
        swipeEdge: 4.0,
        swipeUp: true,
        maxWidth: MediaQuery.of(context).size.width * 0.9,
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        minWidth: MediaQuery.of(context).size.width * 0.8,
        minHeight: MediaQuery.of(context).size.width * 0.8,
        swipeCompleteCallback: (orientation, index) {
          debugPrint(orientation.toString());
          debugPrint(index.toString());
        },
      ),
    );
  }
}
