import 'package:ava_app/initSocket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart';

typedef CallbackType = void Function(dynamic val, String status, bool emit);

class BrigtnessDevice extends StatefulWidget {
  final Map device;
  final CallbackType deviceCallback;

  const BrigtnessDevice({
    super.key,
    required this.device,
    required this.deviceCallback,
  });

  @override
  State<BrigtnessDevice> createState() => _BrigtnessDeviceState();
}

class _BrigtnessDeviceState extends State<BrigtnessDevice> {
  double sliderValue = 0;
  bool sliderState = false;

  void setSliderState(bool state) {
    setState(() => sliderState = state);

    widget.deviceCallback({'status': state, 'value': sliderValue}, state ? "${(sliderValue * 100).toStringAsFixed(1)}%" : "Off", true);
  }

  void setSliderValue(double state, bool emit) {
    setState(() => sliderValue = state);

    widget.deviceCallback({'status': sliderState, 'value': state}, '${(state * 100).toStringAsFixed(1)}%', emit);
  }

  @override
  void initState() {
    if (widget.device["settings"] != null) {
      setState(() {
        sliderValue = widget.device["settings"]['value'];
        sliderState = widget.device["settings"]['status'];
      });
    }

    socket = initSocket();

    socket.on("stateChanged", (data) {
      if (data["mqtt_Id"] == widget.device["mqtt_Id"]) {
        setState(() {
          sliderValue = data['settings']['value'];
          sliderState = data['settings']['status'];
        });
      }
    });
    socket.onDisconnect((data) => Navigator.pop(context));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Color(0xff1E1E1E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          )),
      height: MediaQuery.of(context).size.height * 0.9,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 50, bottom: 75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    widget.device["name"],
                    style: GoogleFonts.heebo(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "Set brightness",
                  style: GoogleFonts.heebo(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 350,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 110,
                  thumbShape: SliderComponentShape.noOverlay,
                  overlayShape: SliderComponentShape.noOverlay,
                  valueIndicatorShape: SliderComponentShape.noOverlay,
                  trackShape: const CustomRoundedRectSliderTrackShape(Radius.circular(20)),
                ),
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Slider(
                    value: sliderValue,
                    min: 0,
                    max: 1,
                    activeColor: sliderState ? Colors.white : Colors.grey[600],
                    inactiveColor: Colors.grey[800],
                    onChanged: (value) => sliderState ? setSliderValue(value, false) : null,
                    onChangeEnd: (value) => sliderState ? setSliderValue(value, true) : null,
                  ),
                ),
              ),
            ),
            CupertinoSlidingSegmentedControl(
              padding: const EdgeInsets.all(7),
              thumbColor: Colors.white,
              children: {
                "on": Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                  child: Text(
                    "On",
                    style: GoogleFonts.heebo(fontSize: 20, fontWeight: FontWeight.w500, color: !sliderState ? Colors.white : const Color(0xff1e1e1e)),
                  ),
                ),
                "off": Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
                  child: Text(
                    "Off",
                    style: GoogleFonts.heebo(fontSize: 20, fontWeight: FontWeight.w500, color: sliderState ? Colors.white : const Color(0xff1e1e1e)),
                  ),
                ),
              },
              groupValue: !sliderState ? "off" : "on",
              onValueChanged: (value) {
                setSliderState(value == "on" ? true : false);
              },
            )
          ],
        ),
      ),
    );
  }
}

class CustomRoundedRectSliderTrackShape extends SliderTrackShape with BaseSliderTrackShape {
  final Radius trackRadius;
  const CustomRoundedRectSliderTrackShape(this.trackRadius);

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    assert(sliderTheme.disabledActiveTrackColor != null);
    assert(sliderTheme.disabledInactiveTrackColor != null);
    assert(sliderTheme.activeTrackColor != null);
    assert(sliderTheme.inactiveTrackColor != null);
    assert(sliderTheme.thumbShape != null);
    if (sliderTheme.trackHeight == null || sliderTheme.trackHeight! <= 0) {
      return;
    }

    final ColorTween activeTrackColorTween = ColorTween(begin: sliderTheme.disabledActiveTrackColor, end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = ColorTween(begin: sliderTheme.disabledInactiveTrackColor, end: sliderTheme.inactiveTrackColor);
    final Paint leftTrackPaint = Paint()..color = activeTrackColorTween.evaluate(enableAnimation)!;
    final Paint rightTrackPaint = Paint()..color = inactiveTrackColorTween.evaluate(enableAnimation)!;

    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    var activeRect = RRect.fromLTRBAndCorners(
      trackRect.left,
      trackRect.top - (additionalActiveTrackHeight / 2),
      thumbCenter.dx,
      trackRect.bottom + (additionalActiveTrackHeight / 2),
      topLeft: trackRadius,
      bottomLeft: trackRadius,
    );
    var inActiveRect = RRect.fromLTRBAndCorners(
      thumbCenter.dx,
      trackRect.top,
      trackRect.right,
      trackRect.bottom,
      topRight: trackRadius,
      bottomRight: trackRadius,
    );
    var percent = ((activeRect.width / (activeRect.width + inActiveRect.width)) * 100).toInt();
    if (percent > 99) {
      activeRect = RRect.fromLTRBAndCorners(
        trackRect.left,
        trackRect.top - (additionalActiveTrackHeight / 2),
        thumbCenter.dx,
        trackRect.bottom + (additionalActiveTrackHeight / 2),
        topLeft: trackRadius,
        bottomLeft: trackRadius,
        bottomRight: trackRadius,
        topRight: trackRadius,
      );
    }

    if (percent < 1) {
      inActiveRect = RRect.fromLTRBAndCorners(
        thumbCenter.dx,
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
        topRight: trackRadius,
        bottomRight: trackRadius,
        bottomLeft: trackRadius,
        topLeft: trackRadius,
      );
    }
    context.canvas.drawRRect(
      activeRect,
      leftTrackPaint,
    );

    context.canvas.drawRRect(
      inActiveRect,
      rightTrackPaint,
    );
  }
}
