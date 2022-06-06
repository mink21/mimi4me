import 'dart:async';
import 'dart:core';
import 'dart:math';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter/services.dart';

class NoiseMeter {
  final AudioStreamer _streamer = AudioStreamer();
  final Function _onError;
  Stream<NoiseReading>? _stream;

  NoiseMeter(this._onError);

  static int get sampleRate => AudioStreamer.sampleRate;

  late StreamController<NoiseReading> _controller;

  Stream<NoiseReading> get noiseStream {
    if (_stream == null) {
      _controller = StreamController<NoiseReading>.broadcast(
          onListen: _start, onCancel: _stop);
      _stream = _controller.stream.handleError(_onError);
    }
    return _stream!;
  }

  void _onAudio(List<double> buffer) {
    _controller.add(NoiseReading(buffer));
  }

  void _onInternalError(PlatformException e) {
    _stream = null;
    _controller.addError(e);
  }

  void _start() async {
    _streamer.start(_onAudio, _onInternalError);
  }

  void _stop() async {
    await _streamer.stop();
  }
}

class NoiseReading {
  late double _meanDecibel, _maxDecibel;
  List<double> _volumes = [];

  NoiseReading(List<double> volumes) {
    _volumes = volumes;
    volumes.sort();

    double min = volumes.first;
    double max = volumes.last;
    double mean = 0.5 * (min.abs() + max.abs());

    double maxAmp = pow(2, 15) + 0.0;

    _maxDecibel = 20 * log(maxAmp * max) * log10e;
    _meanDecibel = 20 * log(maxAmp * mean) * log10e;
  }

  double get maxDecibel => _maxDecibel;

  double get meanDecibel => _meanDecibel;

  List<double> get volumes => _volumes;

  @override
  String toString() {
    return '''[VolumeReading]
      - max dB    $maxDecibel
      - mean dB   $meanDecibel
    ''';
  }
}
