import 'dart:async';
import 'package:flutter/material.dart';
import 'package:voive_recorder_app/Home.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<Splash> with TickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(duration: const Duration(seconds: 1), vsync: this)
        ..repeat();

  @override
  void initState() {
    super.initState();
    Timer(
        const Duration(seconds: 1),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Home())));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
              animation: _controller,
              child: Container(
                height: 200,
                width: 200,
                child: Center(child: Image.asset("images/logo.png")),
              ),
              builder: (BuildContext context, Widget? child) {
                return Transform.scale(
                  scale: _controller.value *
                      2.0, // Scale the widget by 2x when animation completes
                  child: child,
                );
              }),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
          ),
          const Align(
            alignment: Alignment.center,
          )
        ],
      )),
    );
  }
}
