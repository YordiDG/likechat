import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCall extends StatefulWidget {
  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  late final RtcEngine engine;
  final muted = false.obs;
  final localUserJoined = false.obs;
  final videoPaused = false.obs;
  final myRemoteUid = 0.obs;
  final channelId = 'channelId'; // Coloca aquí tu ID de canal

  @override
  void initState() {
    super.initState();
    handlePermissions().then((_) => initializeAgora());
  }

  @override
  void dispose() {
    onCallEnd(); // Asegúrate de finalizar correctamente la llamada
    super.dispose();
  }

  Future<void> handlePermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  Future<void> initializeAgora() async {
    const appId = '48528d5599d845dfa9278c899d2c1113'; // Reemplaza con tu ID de aplicación Agora
    if (appId.isEmpty) {
      throw Exception('Falta la clave del ID de la aplicación Agora');
    }

    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: appId));

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() {
            localUserJoined.value = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() {
            myRemoteUid.value = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() {
            myRemoteUid.value = 0;
          });
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          setState(() {
            localUserJoined.value = false;
          });
        },
      ),
    );

    await engine.enableVideo();
    await engine.startPreview();

    await engine.joinChannel(
      token: 'null',
      channelId: channelId,
      uid: 0,
      options: ChannelMediaOptions(),
    );
  }

  void onToggleMute() {
    muted.value = !muted.value;
    engine.muteLocalAudioStream(muted.value);
  }

  void onCallEnd() {
    engine.leaveChannel();
    engine.release();
  }

  void onToggleCamera() {
    engine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(
            children: [
              // Vista de la cámara local (simulada)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 60,
                child: Container(
                  color: Colors.blueGrey, // Color de fondo para la cámara local simulada
                  child: Center(
                    child: Text(
                      'Cámara local (simulada)',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              // Espacio para el video remoto
              Positioned.fill(
                child: Obx(() => Center(
                  child: localUserJoined.value
                      ? videoPaused.value
                      ? Container(
                    color: Theme.of(context).primaryColor,
                    /*child: Center(
                                child: Text(
                                  "Video remoto pausado",
                                  style: Theme.of(context)
                                      .textTheme
                                      .copyWith(color: Colors.white70),
                                ),
                              ),*/
                  )
                      : Container(
                    color: Colors.black, // Color de fondo para el video remoto
                    child: Center(
                      child: Text(
                        'Vista de video remoto',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                      : Container(
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        'No hay video remoto',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )),
              ),
              // Controles y botones
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: onToggleMute,
                      child: Icon(
                        muted.value ? Icons.mic : Icons.mic_off,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    InkWell(
                      onTap: onCallEnd,
                      child: Icon(
                        Icons.call_end,
                        size: 35,
                        color: Colors.red,
                      ),
                    ),
                    InkWell(
                      onTap: onToggleCamera,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.videocam,
                            size: 25,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: onToggleCamera,
                      child: Icon(
                        Icons.switch_camera,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
