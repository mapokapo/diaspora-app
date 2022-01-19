import 'package:flutter/material.dart';

class AnimatedGradient extends StatefulWidget {
  final Duration duration;
  const AnimatedGradient({required this.duration, Key? key}) : super(key: key);

  @override
  _AnimatedGradientState createState() => _AnimatedGradientState();
}

class _AnimatedGradientState extends State<AnimatedGradient> {
  late List<Color> colorList = [];

  @override
  void initState() {
    super.initState();
    colorList.addAll([
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.primaryVariant,
    ]);
  }

  List<Alignment> alignmentList = [
    Alignment.bottomLeft,
    Alignment.topRight,
  ];

  int index = 0;
  Color bottomColor = Colors.red;
  Color topColor = Colors.yellow;
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(milliseconds: 10), () {
      setState(() {
        bottomColor = Colors.blue;
      });
    });
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      onEnd: () {
        setState(() {
          index = index + 1;
          // animate the color
          bottomColor = colorList[index % colorList.length];
          topColor = colorList[(index + 1) % colorList.length];

          //// animate the alignment
          // begin = alignmentList[index % alignmentList.length];
          // end = alignmentList[(index + 2) % alignmentList.length];
        });
      },
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [bottomColor, topColor],
        ),
      ),
    );
  }
}
