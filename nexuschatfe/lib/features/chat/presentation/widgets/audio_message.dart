import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';

class AudioMessage extends StatefulWidget {
  final String source;
  final bool isSender;

  /// Callback when audio file should be removed
  /// Setting this to null hides the delete button

  const AudioMessage({Key? key, required this.source, this.isSender = false})
    : super(key: key);

  @override
  AudioPlayerState createState() => AudioPlayerState();
}

class AudioPlayerState extends State<AudioMessage> {
  static double _controlSize = 30;

  final _audioPlayer = ap.AudioPlayer();
  late StreamSubscription<void> _playerStateChangedSubscription;
  late StreamSubscription<Duration?> _durationChangedSubscription;
  late StreamSubscription<Duration> _positionChangedSubscription;
  Duration? _position;
  Duration? _duration;

  @override
  void initState() {
    _playerStateChangedSubscription = _audioPlayer.onPlayerComplete.listen((
      state,
    ) async {
      await stop();
      setState(() {});
    });
    _positionChangedSubscription = _audioPlayer.onPositionChanged.listen(
      (position) => setState(() {
        _position = position;
      }),
    );
    _durationChangedSubscription = _audioPlayer.onDurationChanged.listen(
      (duration) => setState(() {
        _duration = duration;
      }),
    );

    super.initState();
  }

  @override
  void dispose() {
    _playerStateChangedSubscription.cancel();
    _positionChangedSubscription.cancel();
    _durationChangedSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _buildControl(),
            const SizedBox(width: 8),
            Expanded(child: _buildSlider(constraints.maxWidth)),
          ],
        );
      },
    );
  }

  Widget _buildControl() {
    Icon icon;
    Color color;

    final theme = Theme.of(context);
    final iconColor = widget.isSender
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.primary;

    if (_audioPlayer.state == ap.PlayerState.playing) {
      icon = Icon(Icons.pause, color: iconColor, size: 30);
      color = iconColor.withOpacity(0.1);
    } else {
      icon = Icon(Icons.play_arrow, color: iconColor, size: 30);
      color = iconColor.withOpacity(0.1);
    }

    return ClipOval(
      child: Material(
        color: color,
        child: InkWell(
          child: Transform.rotate(
            angle: 0,
            child: SizedBox(
              width: _controlSize,
              height: _controlSize,
              child: icon,
            ),
          ),
          onTap: () {
            if (_audioPlayer.state == ap.PlayerState.playing) {
              pause();
            } else {
              play();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSlider(double widgetWidth) {
    bool canSetValue = false;
    final duration = _duration;
    final position = _position;

    if (duration != null && position != null) {
      canSetValue = position.inMilliseconds > 0;
      canSetValue &= position.inMilliseconds < duration.inMilliseconds;
    }

    final theme = Theme.of(context);
    final activeColor = widget.isSender
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.primary;
    final inactiveColor = activeColor.withOpacity(0.3);

    return Slider(
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      onChanged: (v) {
        if (duration != null) {
          final position = v * duration.inMilliseconds;
          _audioPlayer.seek(Duration(milliseconds: position.round()));
        }
      },
      value: canSetValue && duration != null && position != null
          ? position.inMilliseconds / duration.inMilliseconds
          : 0.0,
    );
  }

  Future<void> play() async {
    try {
      print('🎵 Playing audio from: ${widget.source}');
      await _audioPlayer.play(ap.UrlSource(widget.source));
      setState(() {}); // Update UI after starting playback
    } catch (e) {
      print('❌ Error playing audio: $e');
    }
  }

  Future<void> pause() => _audioPlayer.pause();

  Future<void> stop() => _audioPlayer.stop();
}
