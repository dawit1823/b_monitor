//loading_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:r_and_e_monitor/services/helper/loading/loading_screen_controller.dart';

class LoadingScreen {
  factory LoadingScreen() => _shared;
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();

  LoadingScreenController? controller;

  void show({
    required BuildContext context,
    required String text,
    Duration duration = Duration.zero, // Default to no auto-hide
    Color backgroundColor = Colors.black54,
    Color textColor = Colors.black,
    TextStyle? textStyle,
  }) {
    if (controller?.update(text) ?? false) {
      return;
    } else {
      controller = showOverlay(
        context: context,
        text: text,
        duration: duration,
        backgroundColor: backgroundColor,
        textColor: textColor,
        textStyle: textStyle,
      );
    }
  }

  void hide() {
    controller?.close();
    controller = null;
  }

  LoadingScreenController? showOverlay({
    required BuildContext context,
    required String text,
    Duration duration = Duration.zero,
    Color backgroundColor = Colors.black54,
    Color textColor = Colors.black,
    TextStyle? textStyle,
  }) {
    final tempText = StreamController<String>();
    tempText.add(text);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlayState = Overlay.of(context);
      // if (overlayState == null) {
      //   return;
      // }
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) {
        return;
      }
      final size = renderBox.size;

      final overlay = OverlayEntry(builder: (context) {
        return Material(
          color: backgroundColor,
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width * 0.8,
                maxHeight: size.height * 0.8,
                minWidth: size.width * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20.0),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20.0),
                      StreamBuilder<String>(
                        stream: tempText.stream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Text(
                              snapshot.data!,
                              textAlign: TextAlign.center,
                              style: textStyle ??
                                  TextStyle(
                                    color: textColor,
                                    fontSize: 16.0,
                                  ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      });

      overlayState.insert(overlay);

      controller = LoadingScreenController(
        close: () {
          tempText.close();
          overlay.remove();
          return true;
        },
        update: (newText) {
          tempText.add(newText);
          return true;
        },
      );

      if (duration != Duration.zero) {
        Future.delayed(duration, () {
          if (controller != null) {
            controller?.close();
            controller = null;
          }
        });
      }
    });

    return controller;
  }
}
