
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:negamepad/providers/main_provider.dart';
import 'package:negamepad/widgets/game_button.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import '../controlpad/joystick_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  late MainProvider mainProvider=Provider.of<MainProvider>(context,listen: false);


  Set<String> activeDirections = {};

  void _updateDirection(String direction, bool isActive) {
    if (isActive) {
      if (!activeDirections.contains(direction)) {
        activeDirections.add(direction);
        debugPrint("$direction: 1");
        mainProvider.sendKey('keydown', direction);
      }
    } else {
      if (activeDirections.contains(direction)) {
        activeDirections.remove(direction);
        debugPrint("$direction: 0");
        mainProvider.sendKey('keyup', direction);
      }
    }
  }
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainProvider>(builder: (context, state, widget) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: state.isLogin
            ? Row(
              children: [
                Expanded(
                  child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned(
                          top: 150,
                          left: 10,
                          child: JoystickView(
                          onDirectionChanged: (degrees, distance) {
                            _updateDirection("4", (degrees >= 300 || degrees <= 60) && degrees != 0);
                            _updateDirection("6", degrees >= 200 && degrees <= 330);
                            _updateDirection("7", degrees >= 30 && degrees <= 150);
                            _updateDirection("5", degrees >= 120 && degrees <= 240);

                            if (degrees == 0) {
                              for (var direction in activeDirections.toList()) {
                                _updateDirection(direction, false);
                              }
                            }
                          },
                        ),),

                        ...state.buttonModes.map((v) => Positioned(
                            top: v.y ?? 0,
                            left: v.x ?? 0,
                            child: GameButton(
                              buttonMode: v,
                              onDown: (key) {
                                state.sendKey('keydown', key);
                              },
                              onUp: (key) {
                                state.sendKey('keyup', key);
                              },
                            ))),
                      ],
                    ),
                ),
              ],
            )
            :state.isConnected? state.isQR?QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ):Center(child: Card(child: InkWell(
              onTap: (){
                state.isQR=true;
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("QrScan"),
              ),
            ),)):const Center(child: SpinKitHourGlass(color: Colors.orange),),
      );
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {

        mainProvider.login(scanData.code);

    });
  }
}
